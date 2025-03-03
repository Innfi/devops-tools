output "bastion_dns" {
  value = aws_instance.bastion.public_dns
}