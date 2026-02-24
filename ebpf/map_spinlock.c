//go:build ignore

#include <linux/bpf.h>
#include <bpf/bpf_helpers.h>

// Value struct protected by a spinlock.
// bpf_spin_lock MUST be the first field so the verifier can locate it.
struct alloc_val {
	struct bpf_spin_lock lock;
	__u32 address;    // e.g. an IPv4 address or any 32-bit identifier
	__u8  allocated;  // 0 = free, 1 = allocated
	__u8  pad[3];
};

// Map: u32 key -> alloc_val
struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 1024);
	__type(key,   __u32);
	__type(value, struct alloc_val);
} alloc_map SEC(".maps");

// XDP prog that does nothing — map is driven from userspace.
// A real prog would call bpf_spin_lock / bpf_spin_unlock here.
SEC("xdp")
int xdp_spinlock_demo(struct xdp_md *ctx)
{
	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
