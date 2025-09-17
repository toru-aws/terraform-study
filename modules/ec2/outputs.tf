output "ec2_public_ip" {
  value = aws_instance.main_ec2.public_ip
}

output "ec2_id" {
  description = "EC2 instance ID"
  value       = aws_instance.main_ec2.id
}

# RDS用にEC2のSGを渡す
output "ec2_sg_id" {
  value = aws_security_group.ec2_sg.id
}
