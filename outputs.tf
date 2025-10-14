# VPC ID
output "vpc_id" {
  value       = module.vpc.aws_vpc_id
  description = "作成された VPC の ID"
}

# ALB DNS 名
output "alb_dns_name" {
  value       = module.alb.alb_dns_name
  description = "ALB の DNS 名"
}

output "springboot_bucket_name" {
  value = module.s3.springboot_bucket_name
}
