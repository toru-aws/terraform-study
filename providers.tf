terraform {
  required_version = ">= 1.5.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 6.14.1" # ← WAF Logging 用に必須
    }
  }
}

provider "aws" {
  region = "ap-northeast-1" # 東京リージョン
}
