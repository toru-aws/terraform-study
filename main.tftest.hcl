run "vpc_cidr_test" {
  command = plan

  module {
    source = "./modules/vpc"
  }

  assert {
    condition     = output.vpc_cidr == "10.0.0.0/16"
    error_message = "VPCのCIDRは10.0.0.0/16である必要があります"
  }
}

run "vpc_publicsubnet_test" {
  command = apply

  module {
    source = "./modules/vpc"
  }


  assert {
    condition     = output.public_subnets.subnet1.cidr == "10.0.1.0/24"
    error_message = "PublicSubnet1のCIDRが期待と異なります"
  }
  assert {
    condition     = output.public_subnets.subnet1.availability_zone == "ap-northeast-1a"
    error_message = "PublicSubnet1のAZが期待と異なります"
  }
  assert {
    condition     = output.public_subnets.subnet2.cidr == "10.0.3.0/24"
    error_message = "PublicSubnet2のCIDRが期待と異なります"
  }
  assert {
    condition     = output.public_subnets.subnet2.availability_zone == "ap-northeast-1c"
    error_message = "PublicSubnet2のAZが期待と異なります"
  }
}

run "ec2_sg_test" {
  command = plan

  module {
    source = "./modules/ec2"
  }

  # SSHアクセス（ポート22）が設定されているか確認
  assert {
    condition = length([
      for rule in output.ec2_sg_ingress : rule
      if rule.from_port == 22
      && rule.protocol == "tcp"
      && contains(rule.cidr_blocks, var.my_ip)
    ]) == 1
    error_message = "SSH ingressルールが正しくありません"
  }

  # HTTPアクセス（ポート80）が設定されているか確認
  assert {
    condition = length([
      for rule in output.ec2_sg_ingress : rule
      if rule.from_port == 80
      && rule.protocol == "tcp"
      && contains(rule.cidr_blocks, "0.0.0.0/0")
    ]) == 1
    error_message = "HTTP ingressルールが正しくありません"
  }

  # 全通信許可（egress）が設定されているか確認
  assert {
    condition = length([
      for rule in output.ec2_sg_egress : rule
      if rule.protocol == "-1"
      && contains(rule.cidr_blocks, "0.0.0.0/0")
    ]) > 0
    error_message = "Egressルールが正しくありません"
  }
}

  variables {
    vpc_id           = "vpc-dummy"
    public_subnet_id = "subnet-dummy"
    my_ip            = "1.2.3.4/32"
    key_name         = "my-keypair-dummy"
  }
  