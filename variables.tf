variable "db_username" {
  description = "RDS master username (root module)"
  type        = string
}

variable "db_password" {
  description = "RDS master password (root module)"
  type        = string
  sensitive   = true
}
