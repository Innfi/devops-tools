package iptableswrapper

import "github.com/coreos/go-iptables/iptables"

// TODO: any substitutes?

type IPTablesIface interface {
	// Exists(table, chain string, rulespec ...string) (bool, error)
	// Insert(table, chain string, pos int, rulespec ...string) error
	// Append(table, chain string, rulespec ...string) error
	// AppendUnique(table, chain string, rulespec ...string) error
	// Delete(table, chain string, reulespec ...string) error
	List(table, chain string) ([]string, error)
	// NewChain(table, chain string) error
	// ClearChain(table, chain string) error
	// DeleteChain(table, chain string) error
	ListChains(table string) ([]string, error)
	ChainExists(table, chain string) (bool, error)
	// HasRandomFully() bool
}

type ipTables struct {
	ipt *iptables.IPTables
}

func NewIPTables(protocol iptables.Protocol) (IPTablesIface, error) {
	ipt, err := iptables.NewWithProtocol(protocol)
	if err != nil {
		return nil, err
	}

	return &ipTables{ipt: ipt}, nil
}

func (i ipTables) List(table, chain string) ([]string, error) {
	return i.ipt.List(table, chain)
}

func (i ipTables) ListChains(table string) ([]string, error) {
	return i.ipt.ListChains(table)
}

func (i ipTables) ChainExists(table, chain string) (bool, error) {
	return i.ipt.ChainExists(table, chain)
}
