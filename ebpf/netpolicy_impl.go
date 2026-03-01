package main

// TC-based network policy enforcement using eBPF.
//
// The eBPF C source lives in netpolicy.c; bpf2go compiles it and emits
// netpolicy_bpfel.go / netpolicy_bpfeb.go with the netpolicyObjects /
// loadNetpolicyObjects API.
//
// Build:
//   make generate   # compiles netpolicy.c -> netpolicy_bpf*.go
//   go build -o ebpf-demo .
//
// Examples:
//
//   # Default-deny ingress; explicitly allow inbound TCP :8080
//   sudo ./ebpf-demo policy -iface eth0 -dir ingress \
//       -dst-port 8080 -proto tcp -action allow
//
//   # Block egress to a specific IP (default allow everything else)
//   sudo ./ebpf-demo policy -iface eth0 -dir egress \
//       -dst-ip 10.0.0.5 -action deny -default allow
//
//   # Allow all traffic from a specific source in both directions
//   sudo ./ebpf-demo policy -iface eth0 -dir both \
//       -src-ip 192.168.1.10 -action allow -default deny
//
//   # Print current hit counts (no interface attachment)
//   sudo ./ebpf-demo policy -stats

import (
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/link"
	"github.com/cilium/ebpf/rlimit"
)

// policyKey mirrors struct policy_key in netpolicy.c.
//
// IPs use host byte order (matching bpf_ntohl in the BPF program), so
// ipToUint32BE("x.x.x.x") produces the correct uint32 value.
// Port uses host byte order (matching bpf_ntohs), so plain uint16 works.
// 0 in any field is a wildcard that matches any value.
type policyKey struct {
	SrcIP   uint32
	DstIP   uint32
	DstPort uint16
	Proto   uint8
	Pad     uint8
}

// policyVal mirrors struct policy_val in netpolicy.c.
type policyVal struct {
	Action uint8
	Pad    [3]uint8
}

const (
	policyDeny  uint8 = 0
	policyAllow uint8 = 1
)

func RunPolicy(args []string) {
	fs := flag.NewFlagSet("policy", flag.ExitOnError)
	ifaceName := fs.String("iface", "lo", "network interface to attach TC programs")
	srcIP     := fs.String("src-ip", "", "source IP to match (empty = any)")
	dstIP     := fs.String("dst-ip", "", "destination IP to match (empty = any)")
	dstPort   := fs.Uint("dst-port", 0, "destination port to match (0 = any)")
	proto     := fs.String("proto", "any", "protocol: tcp, udp, any")
	action    := fs.String("action", "allow", "rule action: allow or deny")
	direction := fs.String("dir", "ingress", "direction to apply rule: ingress, egress, both")
	defAction := fs.String("default", "deny", "default action when no rule matches: allow or deny")
	statsOnly := fs.Bool("stats", false, "print policy stats then exit (no interface attachment)")
	fs.Parse(args) //nolint:errcheck

	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatalf("removing memlock: %v", err)
	}

	objs := netpolicyObjects{}
	if err := loadNetpolicyObjects(&objs, nil); err != nil {
		log.Fatalf("loading eBPF objects: %v", err)
	}
	defer objs.Close()

	if *statsOnly {
		printPolicyStats(&objs)
		return
	}

	// Set default actions for ingress (index 0) and egress (index 1).
	defByte := policyDeny
	if *defAction == "allow" {
		defByte = policyAllow
	}
	for _, idx := range []uint32{0, 1} {
		if err := objs.DefaultAction.Put(idx, defByte); err != nil {
			log.Fatalf("setting default action: %v", err)
		}
	}

	// Build the policy rule key and value.
	key := policyKey{
		SrcIP:   parseOptionalIP(*srcIP),
		DstIP:   parseOptionalIP(*dstIP),
		DstPort: uint16(*dstPort),
		Proto:   parsePolicyProto(*proto),
	}
	val := policyVal{}
	if *action == "allow" {
		val.Action = policyAllow
	}

	// Insert rule into the requested direction map(s).
	if *direction == "ingress" || *direction == "both" {
		if err := objs.IngressPolicy.Put(key, val); err != nil {
			log.Fatalf("inserting ingress rule: %v", err)
		}
		log.Printf("ingress rule added: %s", policyRuleString(key, *action))
	}
	if *direction == "egress" || *direction == "both" {
		if err := objs.EgressPolicy.Put(key, val); err != nil {
			log.Fatalf("inserting egress rule: %v", err)
		}
		log.Printf("egress rule added: %s", policyRuleString(key, *action))
	}

	// Resolve the interface.
	iface, err := net.InterfaceByName(*ifaceName)
	if err != nil {
		log.Fatalf("interface %s: %v", *ifaceName, err)
	}

	// Attach TC programs to the interface.
	var links []link.Link

	if *direction == "ingress" || *direction == "both" {
		l, err := link.AttachTCX(link.TCXOptions{
			Interface: iface.Index,
			Program:   objs.TcIngressPolicy,
			Attach:    ebpf.AttachTCXIngress,
		})
		if err != nil {
			log.Fatalf("attaching TC ingress to %s: %v", *ifaceName, err)
		}
		links = append(links, l)
		log.Printf("TC ingress policy attached to %s (default: %s)", *ifaceName, *defAction)
	}

	if *direction == "egress" || *direction == "both" {
		l, err := link.AttachTCX(link.TCXOptions{
			Interface: iface.Index,
			Program:   objs.TcEgressPolicy,
			Attach:    ebpf.AttachTCXEgress,
		})
		if err != nil {
			log.Fatalf("attaching TC egress to %s: %v", *ifaceName, err)
		}
		links = append(links, l)
		log.Printf("TC egress policy attached to %s (default: %s)", *ifaceName, *defAction)
	}

	log.Println("Press Ctrl+C to detach.")

	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)
	<-sig

	fmt.Println("\ndetaching policy programs...")
	printPolicyStats(&objs)
	for _, l := range links {
		l.Close()
	}
}

// parseOptionalIP returns 0 (wildcard) for an empty string, otherwise
// converts the dotted-decimal address to host-byte-order uint32, matching
// the bpf_ntohl(ip->saddr/daddr) result stored in the BPF map key.
func parseOptionalIP(s string) uint32 {
	if s == "" {
		return 0
	}
	return ipToUint32BE(s)
}

func parsePolicyProto(s string) uint8 {
	switch s {
	case "tcp":
		return 6
	case "udp":
		return 17
	default:
		return 0 // any
	}
}

func policyRuleString(key policyKey, action string) string {
	src := "*"
	if key.SrcIP != 0 {
		src = policyUint32ToIP(key.SrcIP)
	}
	dst := "*"
	if key.DstIP != 0 {
		dst = policyUint32ToIP(key.DstIP)
	}
	port := "*"
	if key.DstPort != 0 {
		port = fmt.Sprintf("%d", key.DstPort)
	}
	protoStr := "any"
	switch key.Proto {
	case 6:
		protoStr = "tcp"
	case 17:
		protoStr = "udp"
	}
	return fmt.Sprintf("src=%-15s dst=%-15s port=%-5s proto=%-3s => %s",
		src, dst, port, protoStr, action)
}

func printPolicyStats(objs *netpolicyObjects) {
	labels := [4]string{
		"ingress allowed",
		"ingress dropped",
		"egress  allowed",
		"egress  dropped",
	}
	fmt.Println("-- Policy Stats --")
	for i, label := range labels {
		var cnt uint64
		if err := objs.PolicyStats.Lookup(uint32(i), &cnt); err == nil {
			fmt.Printf("  %-18s: %d\n", label, cnt)
		}
	}
}

// policyUint32ToIP converts a big-endian uint32 (as returned by ipToUint32BE)
// to a dotted-decimal IPv4 string.
func policyUint32ToIP(n uint32) string {
	return fmt.Sprintf("%d.%d.%d.%d",
		n>>24, (n>>16)&0xFF, (n>>8)&0xFF, n&0xFF)
}
