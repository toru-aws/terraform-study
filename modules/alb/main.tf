# ALB用セキュリティグループ
resource "aws_security_group" "alb_sg" {
  name        = "aws-study-alb-sg"
  description = "Allow HTTP traffic from internet"
  vpc_id      = var.vpc_id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "aws-study-alb-sg"
  }
}

# Application Load Balancer
resource "aws_lb" "aws-study-alb" {
  name               = "aws-study-alb"
  internal           = false
  load_balancer_type = "application"
  security_groups    = [aws_security_group.alb_sg.id]
  subnets            = var.public_subnet_ids

  tags = {
    Name = "aws-study-alb"
  }
}

# ターゲットグループ
resource "aws_lb_target_group" "aws-study-tg" {
  name     = "aws-study-tg"
  port     = 80
  protocol = "HTTP"
  vpc_id   = var.vpc_id

  health_check {
    path                = "/"
    protocol            = "HTTP"
    matcher             = "200"
    interval            = 30
    healthy_threshold   = 3
    unhealthy_threshold = 3
    timeout             = 5
  }

  tags = {
    Name = "aws-study-tg"
  }
}

# リスナー
resource "aws_lb_listener" "aws-study-listener" {
  load_balancer_arn = aws_lb.aws-study-alb.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.aws-study-tg.arn
  }
}

resource "aws_lb_target_group_attachment" "ec2_attach" {
  target_group_arn = aws_lb_target_group.aws-study-tg.arn
  target_id        = var.ec2_id   # ルートから module.alb に渡す
  port             = 80
}
