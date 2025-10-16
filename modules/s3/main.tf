resource "aws_s3_bucket" "springboot_app" {
  bucket = "my-springboot-app-2025"
  force_destroy = true
  acl    = "private"

  versioning {
    enabled = true
  }

  tags = {
    Name        = "SpringBootApp"
    Environment = "Dev"
  }
}

output "springboot_bucket_name" {
  value = aws_s3_bucket.springboot_app.bucket
}
