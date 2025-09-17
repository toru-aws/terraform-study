# RDS 用セキュリティグループ
resource "aws_security_group" "rds_sg" {
  name        = "aws-study-rds-sg"
  description = "Allow EC2 access to RDS"
  vpc_id      = var.vpc_id

  ingress {
    from_port                = 3306
    to_port                  = 3306
    protocol                 = "tcp"
    security_groups          = [var.ec2_security_group_id]
    description              = "Allow EC2 SG access to RDS"
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-study-rds-sg"
  }
}

# RDS Subnet Group
resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "aws-study-rds-subnetgroup"
  subnet_ids = var.private_subnet_ids
  description = "Subnet group for RDS"

  tags = {
    Name = "aws-study-rds-subnetgroup"
  }
}

# RDS インスタンス
resource "aws_db_instance" "rds_instance" {
  identifier              = "aws-study-rds"
  engine                  = "mysql"
  engine_version          = "8.0.39"
  instance_class          = "db.t4g.micro"
  allocated_storage       = 20
  db_name                 = "awsstudy"
  username                = var.db_username
  password                = var.db_password
  db_subnet_group_name    = aws_db_subnet_group.rds_subnet_group.name
  vpc_security_group_ids  = [aws_security_group.rds_sg.id]
  skip_final_snapshot     = true
  publicly_accessible     = false

  tags = {
    Name = "aws-study-rds"
  }
}
