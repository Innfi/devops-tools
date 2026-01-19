package network

import (
	"test-cni-plugin/pkg/iptableswrapper"
	"test-cni-plugin/pkg/netlinkwrapper"
	"test-cni-plugin/pkg/nswrapper"
	"test-cni-plugin/pkg/vethwrapper"
)

type Network struct {
	netlink  netlinkwrapper.NetLink
	ns       nswrapper.NS
	veth     vethwrapper.Veth
	iptables iptableswrapper.IPTablesIface
}

/* TODO
* func (n *Network) SetupContainerNetwork(args *skel.CmdArgs, conf *config.NetConf) (*current.Result, error) {
    // Orchestrate all operations
}

func (n *Network) TeardownContainerNetwork(args *skel.CmdArgs) error {
    // Clean teardown
}
*
*/
