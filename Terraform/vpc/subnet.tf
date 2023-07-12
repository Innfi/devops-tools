resource "aws_subnet" "TestSubnet" {
    cidr_block = "172.16.10.0/24" 
    vpc_id = aws_vpc.TestVPC.id 
    availability_zone = "ap-northeast-2a"
}

resource "aws_subnet" "TestSubnetDB" {
    cidr_block = "172.16.20.0/24"
    vpc_id = aws_vpc.TestVPC.id
    availability_zone = "ap-northeast-2c"
}