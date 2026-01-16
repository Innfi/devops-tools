package ipam

// FIXME: netlinkwrapper or network
import "github.com/vishvananda/netlink"

type IPAM struct{}

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
