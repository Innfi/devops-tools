package main

import (
	"encoding/binary"
	"flag"
	"fmt"
	"log"
	"net"
	"os"
	"os/signal"
	"syscall"
	"time"

	"github.com/cilium/ebpf/link"
)

func main() {
	if len(os.Args) > 1 && os.Args[1] == "nat" {
		RunNAT(os.Args[2:])
		return
	}

	if len(os.Args) > 1 && os.Args[1] == "spinlock" {
		RunSpinlock()
		return
	}

	ifaceName := flag.String("iface", "lo", "network interface to attach XDP program")
	blockIP := flag.String("block", "", "IPv4 address to block (iptables DROP equivalent)")
	flag.Parse()

	// Load compiled eBPF objects
	objs := counterObjects{}
	if err := loadCounterObjects(&objs, nil); err != nil {
		log.Fatalf("loading eBPF objects: %v", err)
	}
	defer objs.Close()

	// Attach XDP program to the network interface
	iface, err := net.InterfaceByName(*ifaceName)
	if err != nil {
		log.Fatalf("interface %s: %v", *ifaceName, err)
	}

	xdpLink, err := link.AttachXDP(link.XDPOptions{
		Program:   objs.XdpCounter,
		Interface: iface.Index,
	})
	if err != nil {
		log.Fatalf("attaching XDP to %s: %v", *ifaceName, err)
	}
	defer xdpLink.Close()

	log.Printf("XDP program attached to %s", *ifaceName)

	// Block an IP if specified (equivalent to: iptables -A INPUT -s <ip> -j DROP)
	if *blockIP != "" {
		ip := net.ParseIP(*blockIP).To4()
		if ip == nil {
			log.Fatalf("invalid IPv4 address: %s", *blockIP)
		}
		key := binary.LittleEndian.Uint32(ip)
		val := uint8(1)
		if err := objs.BlockedIps.Put(key, val); err != nil {
			log.Fatalf("adding blocked IP: %v", err)
		}
		log.Printf("blocking packets from %s (iptables -A INPUT -s %s -j DROP)", *blockIP, *blockIP)
	}

	// Print packet counts every 2 seconds until interrupted
	sig := make(chan os.Signal, 1)
	signal.Notify(sig, syscall.SIGINT, syscall.SIGTERM)

	ticker := time.NewTicker(2 * time.Second)
	defer ticker.Stop()

	log.Println("reading packet counts (Ctrl+C to stop)...")

	for {
		select {
		case <-ticker.C:
			printCounts(&objs)
		case <-sig:
			fmt.Println("\ndetaching XDP program...")
			return
		}
	}
}

func printCounts(objs *counterObjects) {
	var key uint32
	var val uint64

	iter := objs.PktCount.Iterate()
	found := false
	for iter.Next(&key, &val) {
		found = true
		ip := make(net.IP, 4)
		binary.LittleEndian.PutUint32(ip, key)
		fmt.Printf("  %s => %d packets\n", ip.String(), val)
	}
	if err := iter.Err(); err != nil {
		log.Printf("map iteration error: %v", err)
	}
	if !found {
		fmt.Println("  (no packets captured yet)")
	}
	fmt.Println("---")
}
