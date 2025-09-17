output "web_acl_arn" {
  value = aws_wafv2_web_acl.web_acl.arn
}

output "cloudwatch_log_group_arn" {
  value = aws_cloudwatch_log_group.waf.arn
}