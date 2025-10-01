# VPC ID を外部モジュールに渡す
output "aws_vpc_id" {
  value       = aws_vpc.aws_study_vpc.id
  description = "作成されたVPCのID"
}

output "public_subnets" {
  value = {
    subnet1 = {
      id               = aws_subnet.MyPublicSubnet1.id
      cidr             = aws_subnet.MyPublicSubnet1.cidr_block
      availability_zone = aws_subnet.MyPublicSubnet1.availability_zone
    }
    subnet2 = {
      id               = aws_subnet.MyPublicSubnet2.id
      cidr             = aws_subnet.MyPublicSubnet2.cidr_block
      availability_zone = aws_subnet.MyPublicSubnet2.availability_zone
    }
  }
}


# プライベートサブネット ID（RDS用）
output "private_subnet_ids" {
  value = [
    aws_subnet.PrivateSubnet1.id,
    aws_subnet.PrivateSubnet2.id
  ]
}

# modules/vpc/outputs.tf
output "vpc_cidr" {
  value = aws_vpc.aws_study_vpc.cidr_block
}
