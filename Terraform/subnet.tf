resource "aws_subnet" "TestSubnet" {
    cidr_block = "172.16.10.0/24" 
    vpc_id= aws_vpc.TestVPC.id
}
