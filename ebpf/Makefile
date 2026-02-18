.PHONY: generate build clean run

generate:
	go generate ./...

build: generate
	go build -o ebpf-demo .

run: build
	sudo ./ebpf-demo -iface lo

clean:
	rm -f ebpf-demo xdp/counter_bpf*.go xdp/counter_bpf*.o
