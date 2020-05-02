resource "aws_vpc" "test_vpc" {
    cidr_block = "172.16.0.0/16"
    instance_tenancy = "dedicated" 
    tags = {
        Name = "innfis_vpc"
    }
}