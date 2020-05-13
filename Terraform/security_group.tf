resource "aws_security_group" "test_sg" {
    name = "test_sg"
    vpc_id = aws_vpc.TestVPC.id 

    ingress {
        description = "ssh"
        from_port = 22
        to_port = 22
        protocol = "ssh"
        cidr_blocks = ["172.16.10.0/24"]
    }

    ingress {
        description = "http"
        from_port = 80
        to_port = 80
        protocol = "http"
        cidr_blocks = ["0.0.0.0/0"]
    }
}
