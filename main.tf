# This creates the "box" in AWS to store your backend Docker image
resource "aws_ecr_repository" "backend" {
  name                 = "starttech-backend"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}