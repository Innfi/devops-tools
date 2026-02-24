package main

// Spinlock-protected eBPF map demo.
//
// The eBPF C source lives in map_spinlock.c; bpf2go compiles it and emits
// mapSpinlock_bpfel.go / mapSpinlock_bpfeb.go.
//
// Build:
//   make generate
//   go build -o ebpf-demo .
//
// Run:
//   sudo ./ebpf-demo spinlock

import (
	"fmt"
	"log"

	"github.com/cilium/ebpf"
	"github.com/cilium/ebpf/rlimit"
)

func RunSpinlock() {
	if err := rlimit.RemoveMemlock(); err != nil {
		log.Fatalf("removing memlock: %v", err)
	}

	objs := mapSpinlockObjects{}
	if err := loadMapSpinlockObjects(&objs, nil); err != nil {
		log.Fatalf("loading eBPF objects: %v", err)
	}
	defer objs.Close()

	m := objs.AllocMap

	// --- Write three entries with BPF_F_LOCK ---
	entries := []struct {
		key     uint32
		address uint32
		alloc   uint8
	}{
		{1, 0xC0A80101, 1}, // 192.168.1.1  allocated
		{2, 0xC0A80102, 0}, // 192.168.1.2  free
		{3, 0xC0A80103, 1}, // 192.168.1.3  allocated
	}

	for _, e := range entries {
		val := mapSpinlockAllocVal{
			Address:   e.address,
			Allocated: e.alloc,
		}
		if err := m.Update(e.key, val, ebpf.UpdateAny|ebpf.UpdateLock); err != nil {
			log.Fatalf("Update key=%d: %v", e.key, err)
		}
		fmt.Printf("wrote  key=%d  address=%s  allocated=%d\n",
			e.key, uint32ToIPv4(e.address), e.alloc)
	}

	fmt.Println("---")

	// --- Read entries back with BPF_F_LOCK ---
	for _, e := range entries {
		var val mapSpinlockAllocVal
		if err := m.LookupWithFlags(e.key, &val, ebpf.LookupLock); err != nil {
			log.Fatalf("LookupWithFlags key=%d: %v", e.key, err)
		}
		fmt.Printf("read   key=%d  address=%s  allocated=%d\n",
			e.key, uint32ToIPv4(val.Address), val.Allocated)
	}

	fmt.Println("---")

	// --- Update one entry (mark key=2 as allocated) ---
	updated := mapSpinlockAllocVal{
		Address:   0xC0A80102,
		Allocated: 1,
	}
	if err := m.Update(uint32(2), updated, ebpf.UpdateExist|ebpf.UpdateLock); err != nil {
		log.Fatalf("Update key=2: %v", err)
	}
	fmt.Println("updated key=2 allocated -> 1")

	var check mapSpinlockAllocVal
	if err := m.LookupWithFlags(uint32(2), &check, ebpf.LookupLock); err != nil {
		log.Fatalf("LookupWithFlags key=2: %v", err)
	}
	fmt.Printf("verify key=2  address=%s  allocated=%d\n",
		uint32ToIPv4(check.Address), check.Allocated)
}

func uint32ToIPv4(n uint32) string {
	return fmt.Sprintf("%d.%d.%d.%d",
		(n>>24)&0xFF, (n>>16)&0xFF, (n>>8)&0xFF, n&0xFF)
}
