# AWS VPC Peering Test

# Resources
* Two VPCs with separate CIDRs
* VPC Peering connection
* A RDS instance in the accepter VPC
* An EC2 instance in the requester VPC

# Connection Test
* AWS Network Manager > Reachability Analyzer: from the EC2 instance to the network interface of the RDS instance

# Errors
* cannot invoke cloudposse/vpc-peering/aws module along with the creation of both VPCs
  
