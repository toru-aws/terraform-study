output "alb_dns_name" {
  description = "DNS name of the ALB"
  value       = aws_lb.aws-study-alb.dns_name
}

output "alb_sg_id" {
  description = "ALB Security Group ID"
  value       = aws_security_group.alb_sg.id
}

output "alb_target_group_arn" {
  description = "Target Group ARN"
  value       = aws_lb_target_group.aws-study-tg.arn
}

output "alb_arn" {
  description = "ARN of the ALB"
  value       = aws_lb.aws-study-alb.arn
}