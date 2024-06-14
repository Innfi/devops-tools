resource "aws_instance" "test_instance" {
    ami = "ami-0bea7fd38fabe821a"
    instance_type = "t2.micro" 
}

resource "aws_network_interface" "test_interface" {
    subnet_id = aws_subnet.TestSubnet.id 
    security_groups = [aws_security_group.test_sg.id]
    
    attachment {
        instance = aws_instance.test_instance.id 
        device_index = 0
    }
}
