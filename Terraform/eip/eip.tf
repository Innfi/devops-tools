provider "aws" {
    version = "~> 2.0"
    region = "ap-northeast-2"
    shared_credentials_file = "~/.aws/credentials"
    profile = "InnfisDev"
}

#assume that we have an ec2 instance and an eip already made, and connect each other

resource "aws_instance" "instance_without_eip" {
    ami = "ami-0bea7fd38fabe821a"
    instance_type = "t2.micro" 
}

resource "aws_eip" "eip_test" {
    vpc = true
}

resource "aws_eip_association" "eip_association" {
    instance_id = aws_instance.instance_without_eip.id
    allocation_id = aws_eip.eip_test.id
}

then create an ec2 instance with eip

resource "aws_instance" "instance_with_eip" {
    ami = "ami-0bea7fd38fabe821a"
    instance_type = "t2.micro" 
}

resource "aws_eip" "eip_as_a_gift" {
    instance = aws_instance.instance_with_eip.id 
    vpc = true
}