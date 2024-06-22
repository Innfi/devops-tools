output "ec2_baseline_public_dns" {
  value = aws_instance.starter.public_dns
  description = "ec2.public_dns"
}