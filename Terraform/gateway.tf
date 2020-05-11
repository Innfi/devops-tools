resource "aws_internet_gateway" "TestGateway" {
    vpc_id = aws_vpc.TestVPC.id
}