output "ec2_high_cpu_alarm" {
  description = "CloudWatch Alarm for EC2 High CPU"
  value       = aws_cloudwatch_metric_alarm.ec2_high_cpu.id
}
