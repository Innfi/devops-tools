output "security_group" {
  description = "The security group created for initial access"
  value       = aws_security_group.initial.*
}