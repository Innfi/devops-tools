# Cilium with EKS Learning & Exercise Todo List

## Setup & Prerequisites
- [x] Install AWS CLI and configure credentials
- [x] Install kubectl and verify cluster access
- [x] Install Helm 3.x or later
- [x] Familiarize with EKS cluster networking basics
- [x] set KUBE_CONFIG_PATH
- [ ] Review Cilium documentation and architecture overview

## EKS Cluster Preparation
- [x] Create EKS cluster with appropriate IAM roles and security groups
- [ ] Verify cluster meets Cilium prerequisites (kernel version 4.9+)
- [ ] Configure VPC CNI (if applicable) or prepare for Cilium replacement
- [ ] Verify node-to-node communication
- [x] Check security group rules allow inter-node traffic

## Cilium Installation & Deployment
- [x] Install Cilium using Helm chart on EKS cluster
- [x] Configure Cilium for AWS/EKS environment (ENI mode, IP addressing)
- [x] Install Cilium CLI tool for testing and troubleshooting
- [ ] Verify Cilium pods are running on all nodes
- [ ] Check Cilium status and agent health

## Basic Cilium Features
- [ ] Enable and test network policies (default deny/allow)
- [ ] Create basic ingress/egress network policies
- [ ] Test microservices communication with policies in place
- [ ] Monitor traffic with Cilium metrics and logs
- [ ] Explore Cilium Hub for policy management (optional)

## Service Mesh & Load Balancing
- [ ] Configure service mesh mode in Cilium
- [ ] Test service-to-service communication through Cilium
- [ ] Implement load balancing with Cilium
- [ ] Test failover and high availability scenarios
- [ ] Monitor service mesh traffic patterns

## Advanced Features
- [ ] Enable and configure DNS policy filtering
- [ ] Set up API-aware network policies (Layer 7)
- [ ] Test HTTP header-based routing
- [ ] Implement security policies based on identity
- [ ] Configure mutual TLS (mTLS) if using Cilium with encryption

## Observability & Monitoring
- [ ] Set up Hubble for network observability
- [ ] Install and configure Hubble UI for visualization
- [ ] Create dashboards for Cilium metrics (Prometheus/Grafana)
- [ ] Configure Cilium logs and alerts
- [ ] Practice troubleshooting with Cilium CLI commands

## Security Practices
- [ ] Implement zero-trust networking model
- [ ] Create identity-based access policies
- [ ] Test threat detection and response
- [ ] Implement egress filtering and DLP policies
- [ ] Audit and validate policy enforcement

## Performance & Optimization
- [ ] Benchmark Cilium performance impact
- [ ] Tune Cilium for optimal throughput and latency
- [ ] Configure eBPF options for specific use cases
- [ ] Test under high load conditions
- [ ] Analyze resource usage (CPU, memory)

## Integration & Ecosystem
- [ ] Integrate Cilium with AWS security services (VPC Flow Logs, GuardDuty)
- [ ] Connect Cilium monitoring to CloudWatch
- [ ] Explore Cilium + Istio integration (optional)
- [ ] Implement multi-cluster networking (if applicable)
- [ ] Test with multi-cluster service discovery

## Testing & Validation
- [ ] Create test scenarios for policy enforcement
- [ ] Test node failure and recovery scenarios
- [ ] Validate traffic encryption and security
- [ ] Performance test with realistic workloads
- [ ] Document test results and findings

## Production Readiness
- [ ] Create disaster recovery plan
- [ ] Document Cilium configuration and policies
- [ ] Plan upgrade strategy for Cilium versions
- [ ] Implement monitoring and alerting for production
- [ ] Create runbooks for common troubleshooting scenarios
- [ ] Plan capacity and resource management strategy

## Documentation & Knowledge Sharing
- [ ] Document cluster-specific configurations
- [ ] Create architecture diagrams
- [ ] Write troubleshooting guides
- [ ] Document best practices learned
- [ ] Share knowledge with team members
