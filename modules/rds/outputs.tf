output "rds_endpoint" {
  description = "RDS endpoint address"
  value       = aws_db_instance.rds_instance.endpoint
}

output "rds_id" {
  description = "RDS instance ID"
  value       = aws_db_instance.rds_instance.id
}

output "rds_sg_id" {
  description = "RDS Security Group ID"
  value       = aws_security_group.rds_sg.id
}
