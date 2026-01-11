package netlinkwrapper

import (
	"github.com/vishvananda/netlink"
)

type Netlink interface {
	LinkList() ([]netlink.Link, error)
}

type netLink struct {
}

func NewNetlink() NetLink {
	return &netLink{}
}

func (*netLink) ListList() ([]netlink.Link, error) {
	return netlink.LinkList()
}
