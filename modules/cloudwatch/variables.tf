variable "ec2_id" {
  description = "EC2 instance ID to monitor"
  type        = string
}

variable "notification_email" {
  description = "アラート通知先メールアドレス"
  type        = string
  sensitive   = true
}