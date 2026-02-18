//go:build ignore

#include <linux/bpf.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <bpf/bpf_helpers.h>

// Map: source IPv4 address -> packet count
struct {
	__uint(type, BPF_MAP_TYPE_LRU_HASH);
	__uint(max_entries, 4096);
	__type(key, __u32);
	__type(value, __u64);
} pkt_count SEC(".maps");

// Map: blocked IPv4 addresses (iptables DROP equivalent)
struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 256);
	__type(key, __u32);
	__type(value, __u8);
} blocked_ips SEC(".maps");

SEC("xdp")
int xdp_counter(struct xdp_md *ctx) {
	void *data = (void *)(long)ctx->data;
	void *data_end = (void *)(long)ctx->data_end;

	// Parse ethernet header
	struct ethhdr *eth = data;
	if ((void *)(eth + 1) > data_end)
		return XDP_PASS;

	// Only handle IPv4
	if (eth->h_proto != __constant_htons(ETH_P_IP))
		return XDP_PASS;

	// Parse IP header
	struct iphdr *ip = (void *)(eth + 1);
	if ((void *)(ip + 1) > data_end)
		return XDP_PASS;

	__u32 src_ip = ip->saddr;

	// Check if source IP is blocked (iptables -A INPUT -s <ip> -j DROP)
	__u8 *blocked = bpf_map_lookup_elem(&blocked_ips, &src_ip);
	if (blocked)
		return XDP_DROP;

	// Increment packet counter for this source IP
	__u64 *count = bpf_map_lookup_elem(&pkt_count, &src_ip);
	if (count) {
		__sync_fetch_and_add(count, 1);
	} else {
		__u64 init_val = 1;
		bpf_map_update_elem(&pkt_count, &src_ip, &init_val, BPF_ANY);
	}

	return XDP_PASS;
}

char _license[] SEC("license") = "GPL";
