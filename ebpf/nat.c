//go:build ignore

#include <linux/bpf.h>
#include <linux/pkt_cls.h>
#include <linux/if_ether.h>
#include <linux/ip.h>
#include <linux/tcp.h>
#include <linux/udp.h>
#include <linux/in.h>
#include <bpf/bpf_helpers.h>
#include <bpf/bpf_endian.h>

// Byte offsets within an IPv4 packet (after eth header).
#define IP_DST_OFF   (ETH_HLEN + offsetof(struct iphdr, daddr))
#define IP_CSUM_OFF  (ETH_HLEN + offsetof(struct iphdr, check))

// TCP checksum offset from the start of the packet.
#define TCP_CSUM_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, check))
#define TCP_DST_OFF  (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct tcphdr, dest))

// UDP checksum offset from the start of the packet.
#define UDP_CSUM_OFF (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct udphdr, check))
#define UDP_DST_OFF  (ETH_HLEN + sizeof(struct iphdr) + offsetof(struct udphdr, dest))

struct nat_key {
	__u32 dst_ip;
	__u16 dst_port;
	__u8  proto;   // IPPROTO_TCP or IPPROTO_UDP
	__u8  pad;
};

struct nat_target {
	__u32 new_ip;
	__u16 new_port;
	__u8  pad[2];
};

// Map: nat_key -> nat_target
struct {
	__uint(type, BPF_MAP_TYPE_HASH);
	__uint(max_entries, 256);
	__type(key,   struct nat_key);
	__type(value, struct nat_target);
} nat_rules SEC(".maps");

SEC("tc")
int tc_dnat(struct __sk_buff *skb)
{
	void *data     = (void *)(long)skb->data;
	void *data_end = (void *)(long)skb->data_end;

	// --- Ethernet ---
	struct ethhdr *eth = data;
	if ((void *)(eth + 1) > data_end)
		return TC_ACT_OK;
	if (eth->h_proto != bpf_htons(ETH_P_IP))
		return TC_ACT_OK;

	// --- IPv4 ---
	struct iphdr *ip = (void *)(eth + 1);
	if ((void *)(ip + 1) > data_end)
		return TC_ACT_OK;

	__u8 proto = ip->protocol;
	if (proto != IPPROTO_TCP && proto != IPPROTO_UDP)
		return TC_ACT_OK;

	// --- L4 destination port ---
	__u16 dst_port;
	if (proto == IPPROTO_TCP) {
		struct tcphdr *tcp = (void *)(ip + 1);
		if ((void *)(tcp + 1) > data_end)
			return TC_ACT_OK;
		dst_port = bpf_ntohs(tcp->dest);
	} else {
		struct udphdr *udp = (void *)(ip + 1);
		if ((void *)(udp + 1) > data_end)
			return TC_ACT_OK;
		dst_port = bpf_ntohs(udp->dest);
	}

	// --- Lookup NAT rule ---
	struct nat_key key = {
		.dst_ip   = bpf_ntohl(ip->daddr),
		.dst_port = dst_port,
		.proto    = proto,
		.pad      = 0,
	};
	struct nat_target *target = bpf_map_lookup_elem(&nat_rules, &key);
	if (!target)
		return TC_ACT_OK;

	__u32 new_ip_be   = bpf_htonl(target->new_ip);
	__u16 new_port_be = bpf_htons(target->new_port);

	// --- Rewrite destination IP ---
	// Update IP checksum first (L3, no pseudo-header flag).
	bpf_l3_csum_replace(skb, IP_CSUM_OFF, ip->daddr, new_ip_be, sizeof(__u32));
	bpf_skb_store_bytes(skb, IP_DST_OFF, &new_ip_be, sizeof(__u32), 0);

	// --- Rewrite destination port + update L4 checksum ---
	// BPF_F_PSEUDO_HDR tells the helper to also account for the IP address
	// change in the pseudo-header of the TCP/UDP checksum.
	if (proto == IPPROTO_TCP) {
		// Account for the IP address change in the TCP checksum pseudo-header.
		bpf_l4_csum_replace(skb, TCP_CSUM_OFF, ip->daddr, new_ip_be,
				    BPF_F_PSEUDO_HDR | sizeof(__u32));
		// Account for the port change.
		struct tcphdr *tcp2 = (void *)(long)skb->data + ETH_HLEN + sizeof(struct iphdr);
		bpf_l4_csum_replace(skb, TCP_CSUM_OFF, tcp2->dest, new_port_be, sizeof(__u16));
		bpf_skb_store_bytes(skb, TCP_DST_OFF, &new_port_be, sizeof(__u16), 0);
	} else {
		// UDP: same pattern; 0 UDP checksum means skip update.
		struct udphdr *udp2 = (void *)(long)skb->data + ETH_HLEN + sizeof(struct iphdr);
		if (udp2->check != 0) {
			bpf_l4_csum_replace(skb, UDP_CSUM_OFF, ip->daddr, new_ip_be,
					    BPF_F_PSEUDO_HDR | sizeof(__u32));
			bpf_l4_csum_replace(skb, UDP_CSUM_OFF, udp2->dest, new_port_be,
					    sizeof(__u16));
		}
		bpf_skb_store_bytes(skb, UDP_DST_OFF, &new_port_be, sizeof(__u16), 0);
	}

	return TC_ACT_OK;
}

char _license[] SEC("license") = "GPL";
