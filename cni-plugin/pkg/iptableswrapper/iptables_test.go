package iptableswrapper

import (
	"fmt"
	"testing"

	"github.com/coreos/go-iptables/iptables"
	"github.com/go-playground/assert/v2"
	"github.com/stretchr/testify/assert"
)

func TestInit(t *testing.T) {
	instance, err := NewIPTables(iptables.ProtocolIPv4)
	assert.Equal(t, err, nil)

	chains, err := instance.ListChains("filter")
	assert.Equal(t, err, nil)

	for _, elem := range chains {
		fmt.Println(elem)
	}
}
