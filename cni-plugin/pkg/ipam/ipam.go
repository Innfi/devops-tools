package ipam

// FIXME: netlinkwrapper or network
import "github.com/vishvananda/netlink"

type IPAM struct {
	subnet string
}

func NewIPAM(subnet string) IPAM {
	return IPAM{subnet: subnet}
}

func (ipam *IPAM) BindNewAddr(link netlink.Link) error {
	addr, err := ipam.newAddr()
	if err != nil {
		return err
	}

	return netlink.AddrAdd(link, addr)
}

func (*IPAM) newAddr() (*netlink.Addr, error) {
	// FIXME
	return netlink.ParseAddr("10.244.0.2/24")
}
