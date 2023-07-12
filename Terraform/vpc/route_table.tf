resource "aws_route_table" "TestRouteTable" {
    vpc_id = aws_vpc.TestVPC.id 
    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.TestGateway.id
    }
}
