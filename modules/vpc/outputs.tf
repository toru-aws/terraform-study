# VPC ID を外部モジュールに渡す
output "aws_vpc_id" {
  value       = aws_vpc.aws_study_vpc.id
  description = "作成されたVPCのID"
}

# パブリックサブネット1 の ID を外部に渡す
output "public_subnet1_id" {
  value       = aws_subnet.MyPublicSubnet1.id
}

# パブリックサブネット2 の ID を外部に渡す
output "public_subnet2_id" {
  value = aws_subnet.MyPublicSubnet2.id
}

# プライベートサブネット ID（RDS用）
output "private_subnet_ids" {
  value = [
    aws_subnet.PrivateSubnet1.id,
    aws_subnet.PrivateSubnet2.id
  ]
}