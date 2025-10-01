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

output "rds_instance_summary" {
  value = {
    identifier        = aws_db_instance.rds_instance.identifier
    engine            = aws_db_instance.rds_instance.engine
    engine_version    = aws_db_instance.rds_instance.engine_version
    instance_class    = aws_db_instance.rds_instance.instance_class
    allocated_storage = aws_db_instance.rds_instance.allocated_storage
    db_name           = aws_db_instance.rds_instance.db_name
  }
}
