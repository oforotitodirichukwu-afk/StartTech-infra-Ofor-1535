resource "aws_ecr_repository" "backend" {
  name                 = "starttech-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}


resource "aws_ecr_repository" "frontend" {
  name                 = "starttech-frontend"
  image_tag_mutability = "MUTABLE"
}


resource "aws_s3_bucket" "app_storage" {
  bucket = "starttech-ofor-1535-unique-storage" # Keep the unique name
}


resource "aws_s3_bucket_public_access_block" "app_storage_block" {
  bucket = aws_s3_bucket.app_storage.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}