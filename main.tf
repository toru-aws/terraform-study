module "vpc" {
  source = "./modules/vpc"
}

module "ec2" {
  source           = "./modules/ec2"
  vpc_id           = module.vpc.aws_vpc_id
  public_subnet_id = module.vpc.public_subnets["subnet1"].id
  key_name         = var.key_name # 作成済みキーペア名
  my_ip            = var.my_ip
}

output "ec2_public_ip" {
  value = module.ec2.ec2_public_ip
}

output "ec2_id" {
  value = module.ec2.ec2_id
}

module "rds" {
  source                = "./modules/rds"
  vpc_id                = module.vpc.aws_vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  ec2_security_group_id = module.ec2.ec2_sg_id

  # terraform.tfvars に書いた値を.rds.variables.tfに渡す
  db_username = var.db_username
  db_password = var.db_password
}

module "alb" {
  source = "./modules/alb"
  vpc_id = module.vpc.aws_vpc_id
  public_subnet_ids = [
    module.vpc.public_subnets["subnet1"].id,
    module.vpc.public_subnets["subnet2"].id
  ]
  ec2_id = module.ec2.ec2_id
}

module "cloudwatch" {
  source             = "./modules/cloudwatch"
  ec2_id             = module.ec2.ec2_id
  notification_email = var.notification_email #ハードコードから変数に変更
}

module "waf" {
  source         = "./modules/waf"
  alb_arn        = module.alb.alb_arn # ← ここを修正
  log_group_name = "/aws-waf-logs/aws-study"
}
# WAF と ALB を関連付けるリソース
resource "aws_wafv2_web_acl_association" "alb_waf" {
  resource_arn = module.alb.alb_arn     # ALBモジュールが出力した値
  web_acl_arn  = module.waf.web_acl_arn # WAFモジュールが出力した値
}
