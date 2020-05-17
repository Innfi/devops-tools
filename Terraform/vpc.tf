provider "aws" {
    region = "ap-northeast-2"
}

resource "aws_vpc" "TestVPC" {
    cidr_block = "172.16.0.0/16"
    instance_tenancy = "dedicated" 
    tags = {
        Name = "innfis_vpc"
    }
}
