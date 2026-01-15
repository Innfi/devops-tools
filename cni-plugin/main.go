package main

import (
	"encoding/json"
	"fmt"
	"net"

	"github.com/containernetworking/cni/pkg/skel"
	"github.com/containernetworking/cni/pkg/types"
	current "github.com/containernetworking/cni/pkg/types/100"
	"github.com/containernetworking/plugins/pkg/ns"
	"github.com/vishvananda/netlink"

	iptableswrapper "test-cni-plugin/pkg/iptableswrapper"
	netlinkwrapper "test-cni-plugin/pkg/netlinkwrapper"
	nswrapper "test-cni-plugin/pkg/nswrapper"
)

type NetConf struct {
	types.NetConf
	Subnet string `json:"subnet"`
	Bridge string `json:"bridge"`
}

func cmdAdd(args *skel.CmdArgs) error {
	conf := NetConf{}
	if err := json.Unmarshal(args.StdinData, &conf); err != nil {
		return fmt.Errorf("failed to parse config: %v", err)
	}

	hostVeth := fmt.Sprintf("veth%s", args.ContainerID[:8])
	containerVeth := args.IfName

	netns, err := nswrapper.GetNS(args.Netns)
	if err != nil {
		return fmt.Errorf("failed to open netns: %v", err)
	}
	defer netns.Close()

	veth := &netlink.Veth{
		LinkAttrs: netlink.LinkAttrs{Name: hostVeth},
		PeerName:  containerVeth,
	}
	if err := netlink.LinkAdd(veth); err != nil {
		return fmt.Errorf("failed to create veth pair: %v", err)
	}

	containerIface, err := netlinkwrapper.LinkByName(containerVeth)
	if err != nil {
		return err
	}
	if err := netlinkwrapper.LinkSetNsFd(containerIface, int(netns.Fd())); err != nil {
		return err
	}

	if err := netns.Do(func(_ ns.NetNS) error {
		link, err := netlinkwrapper.LinkByName(containerVeth)
		if err != nil {
			return err
		}

		// TODO: replace this code with ipam
		addr, _ := netlinkwrapper.ParseAddr("10.244.0.2/24")
		if err := netlinkwrapper.AddrAdd(link, addr); err != nil {
			return err
		}

		if err := netlinkwrapper.LinkSetUp(link); err != nil {
			return err
		}

		return nil
	}); err != nil {
		return err
	}

	// set result
	result := &current.Result{
		CNIVersion: conf.CNIVersion,
		Interfaces: []*current.Interface{
			{Name: containerVeth},
		},
		IPs: []*current.IPConfig{
			{
				Address: net.IPNet{
					IP:   net.ParseIP("10.244.0.2"),
					Mask: net.CIDRMask(24, 32),
				},
			},
		},
	}

	return types.PrintResult(result, conf.CNIVersion)
}

func cmdDel(args *skel.CmdArgs) error {
	hostVeth := fmt.Sprintf("veth%s", args.ContainerID[:8])

	link, err := netlinkwrapper.LinkByName(hostVeth)
	if err != nil {
		return err
	}

	return netlinkwrapper.LinkDel(link)
}

func cmdCheck(args *skel.CmdArgs) error {
	return nil
}

func main() {
	fmt.Println("main")

	iptableswrapper.TestRunIptables()

	nswrapper.TestNS()

	netlinkwrapper.TestNetLink()
	// skel.PluginMainFuncs(skel.CNIFuncs{
	// 	Add:   cmdAdd,
	// 	Del:   cmdDel,
	// 	Check: cmdCheck,
	// }, version.All, "test-cni v0.0.1")
}
