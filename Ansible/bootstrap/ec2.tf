resource "aws_instance" "ansible-target1" {
    ami = "ami-00edfb46b107f643c"
    instance_type = "t2.micro"
		key_name="InnfisKey" 
		tags = {
			Name = "AnsibleTarget1"
		}
}

resource "aws_instance" "ansible-target2" {
    ami = "ami-00edfb46b107f643c"
    instance_type = "t2.micro"
		key_name="InnfisKey" 
		tags = {
			Name = "AnsibleTarget2"
		}
}
