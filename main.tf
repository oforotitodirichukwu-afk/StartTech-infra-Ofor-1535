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
# 1. Automatically get your AWS Account ID
data "aws_caller_identity" "current" {}

# 2. Create the IAM Role so App Runner can talk to ECR
resource "aws_iam_role" "apprunner_role" {
  name = "AppRunnerECRAccessRole"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "build.apprunner.amazonaws.com"
        }
      },
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "tasks.apprunner.amazonaws.com"
        }
      }
    ]
  })
}

# 3. Attach the ECR Policy to the Role
resource "aws_iam_role_policy_attachment" "apprunner_policy" {
  role       = aws_iam_role.apprunner_role.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSAppRunnerServicePolicyForECRAccess"
}

# 4. Final App Runner Service
resource "aws_apprunner_service" "backend" {
  service_name = "starttech-backend-service"

  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.backend.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        port = "8080"
        
        runtime_environment_variables = {
          # We added the database name "starttech" before the "?" to ensure it connects to a specific DB
          "MONGODB_URI" = "mongodb+srv://oforotitodirichukwu_db_user:AUGfXdEJvsHP1MQ2@cluster0.ix564om.mongodb.net/starttech?retryWrites=true&w=majority&appName=Cluster0"
        }
      }
    }
    auto_deployments_enabled = true
  }

  health_check_configuration {
    protocol            = "TCP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}
# 5. Frontend Service
resource "aws_apprunner_service" "frontend" {
  service_name = "starttech-frontend-service"
  source_configuration {
    authentication_configuration {
      access_role_arn = aws_iam_role.apprunner_role.arn
    }
    image_repository {
      image_identifier      = "${aws_ecr_repository.frontend.repository_url}:latest"
      image_repository_type = "ECR"
      image_configuration {
        # Create React App production containers usually run on port 80
        port = "80" 
        
        runtime_environment_variables = {
          # This connects your UI to your live Go API
          "VITE_API_URL" = "https://93hrzaeur2.us-east-1.awsapprunner.com"
        }
      }
    }
    auto_deployments_enabled = true
  }

  health_check_configuration {
    protocol            = "TCP"
    interval            = 10
    timeout             = 5
    healthy_threshold   = 2
    unhealthy_threshold = 5
  }
}
# --- OUTPUTS (This is what you were missing) ---

output "backend_url" {
  value = "https://${aws_apprunner_service.backend.service_url}"
}

output "frontend_url" {
  value = "https://${aws_apprunner_service.frontend.service_url}"
}