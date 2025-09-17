variable "vpc_id" {
  description = "作成済みVPCのID"
  type        = string
}

variable "public_subnet_id" {
  description = "EC2を配置するパブリックサブネットID"
  type        = string
}

variable "key_name" {
  description = "作成済みSSHキーペア名"
  type        = string
}