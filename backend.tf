terraform {
  backend "s3" {
    bucket = "terraform-backend-20250904" # ← 作成済みS3バケット名を記入
    key    = "terraform.tfstate"
    region = "ap-northeast-1"
  }
}
