variable "db_username" {
  description = "RDS master username (root module)"
  type        = string
}

variable "db_password" {
  description = "RDS master password (root module)"
  type        = string
  sensitive   = true
}

variable "key_name" {
  description = "EC2で使用するSSHキーペア名"
  type        = string
}

variable "notification_email" {
  description = "アラーム通知用メールアドレス"
  type        = string
  sensitive   = true
}

variable "my_ip" {
  description = "管理者アクセス用固定IP"
  type        = string
}

variable "vpc_id" {
  type    = string
  default = "vpc-dummy"
}

variable "public_subnet_id" {
  type    = string
  default = "subnet-dummy"
}
