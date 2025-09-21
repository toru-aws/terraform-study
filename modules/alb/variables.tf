variable "vpc_id" {
  description = "VPC ID"
  type        = string
}

variable "public_subnet_ids" {
  description = "List of public subnet IDs for ALB"
  type        = list(string)
}

variable "ec2_id" {
  description = "EC2 instance ID to attach to Target Group"
  type        = string
}
