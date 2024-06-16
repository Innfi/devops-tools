output "ec2_baseline_public_ip" {
  value = aws_instance.starter.public_ip
  description = "ec2.public_ip"
}