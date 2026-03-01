//go:build ignore

// TC-based network policy enforcement.
//
// Two TC programs are provided:
//   tc_ingress_policy  – attached to interface ingress
//   tc_egress_policy   – attached to interface egress
//
// Policy rules are stored in per-direction HASH maps keyed by
// (src_ip, dst_ip, dst_port, proto).  A value of 0 in any field
// acts as a wildcard ("any").  The lookup tries progressively
// less-specific keys until a match is found; if none matches the
// per-direction default action applies (default: DROP).
//
// Stats counters (ARRAY map, 4 slots):
//   [0] ingress allowed   [1] ingress dropped
//   [2] egress  allowed   [3] egress  dropped

#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/in.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

#define ACTION_DENY  0
#define ACTION_ALLOW 1

// IPs are stored in host byte order (bpf_ntohl applied).
// Port is stored in host byte order (bpf_ntohs applied).
// 0 in any field means wildcard ("any").
struct policy_key {
	__u32 src_ip;
	__u32 dst_ip;
	__u16 dst_port;
	__u8  proto;    // 0 = any, 6 = TCP, 17 = UDP
	__u8  pad;
};

struct policy_val {
	__u8 action;    // ACTION_DENY or ACTION_ALLOW
	__u8 pad[3];
};

struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 256);
	__type(key,   struct policy_key);
	__type(value, struct policy_val);
} ingress_policy SEC(".maps");

struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 256);
	__type(key,   struct policy_key);
	__type(value, struct policy_val);
} egress_policy SEC(".maps");

// Stats: [0]=ingress_allow [1]=ingress_drop [2]=egress_allow [3]=egress_drop
struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__uint(max_entries, 4);
	__type(key,   __u32);
	__type(value, __u64);
} policy_stats SEC(".maps");

// Default action per direction: index 0 = ingress, 1 = egress.
struct {
	__uint(type, BPF_MAP_TYPE_ARRAY);
	__uint(max_entries, 2);
	__type(key,   __u32);
	__type(value, __u8);
} default_action SEC(".maps");

// lookup_policy probes a policy map with progressively coarser keys,
// returning the matched action byte or 0xFF when no rule applies.
static __always_inline __u8 lookup_policy(void *policy_map,
					   __u32 src_ip, __u32 dst_ip,
					   __u16 dst_port, __u8 proto)
{
	struct policy_key key = {};
	struct policy_val *val;

	// 1. Exact match
	key.src_ip = src_ip; key.dst_ip = dst_ip;
	key.dst_port = dst_port; key.proto = proto;
	val = bpf_map_lookup_elem(policy_map, &key);
	if (val) return val->action;

	// 2. Any source
	key.src_ip = 0;
	val = bpf_map_lookup_elem(policy_map, &key);
	if (val) return val->action;

	// 3. Any source + any destination
	key.dst_ip = 0;
	val = bpf_map_lookup_elem(policy_map, &key);
	if (val) return val->action;

	// 4. Any source + any destination + any port
	key.dst_port = 0;
	val = bpf_map_lookup_elem(policy_map, &key);
	if (val) return val->action;

	// 5. Catch-all (any proto too)
	key.proto = 0;
	val = bpf_map_lookup_elem(policy_map, &key);
	if (val) return val->action;

	return 0xFF; // no matching rule
}

static __always_inline int enforce_policy(struct __sk_buff *skb,
					   void *policy_map,
					   __u32 allow_idx, __u32 drop_idx,
					   __u32 default_idx)
{
	void *data     = (void *)(long)skb->data;
	void *data_end = (void *)(long)skb->data_end;

	struct ethhdr *eth = data;
	if ((void *)(eth + 1) > data_end)
		return TC_ACT_OK;
	if (eth->h_proto != bpf_htons(ETH_P_IP))
		return TC_ACT_OK;

	struct iphdr *ip = (void *)(eth + 1);
	if ((void *)(ip + 1) > data_end)
		return TC_ACT_OK;

	__u32 src_ip   = bpf_ntohl(ip->saddr);
	__u32 dst_ip   = bpf_ntohl(ip->daddr);
	__u8  proto    = ip->protocol;
	__u16 dst_port = 0;

	if (proto == IPPROTO_TCP) {
		struct tcphdr *tcp = (void *)(ip + 1);
		if ((void *)(tcp + 1) > data_end)
			return TC_ACT_OK;
		dst_port = bpf_ntohs(tcp->dest);
	} else if (proto == IPPROTO_UDP) {
		struct udphdr *udp = (void *)(ip + 1);
		if ((void *)(udp + 1) > data_end)
			return TC_ACT_OK;
		dst_port = bpf_ntohs(udp->dest);
	}

	__u8 action = lookup_policy(policy_map, src_ip, dst_ip, dst_port, proto);
	if (action == 0xFF) {
		// No rule matched — consult the per-direction default.
		__u8 *def = bpf_map_lookup_elem(&default_action, &default_idx);
		action = def ? *def : ACTION_DENY;
	}

	__u32 stat_idx = (action == ACTION_ALLOW) ? allow_idx : drop_idx;
	__u64 *cnt = bpf_map_lookup_elem(&policy_stats, &stat_idx);
	if (cnt)
		__sync_fetch_and_add(cnt, 1);

	return (action == ACTION_ALLOW) ? TC_ACT_OK : TC_ACT_SHOT;
}

SEC("tc")
int tc_ingress_policy(struct __sk_buff *skb)
{
	return enforce_policy(skb, &ingress_policy, 0, 1, 0);
}

SEC("tc")
int tc_egress_policy(struct __sk_buff *skb)
{
	return enforce_policy(skb, &egress_policy, 2, 3, 1);
}

char _license[] SEC("license") = "GPL";
