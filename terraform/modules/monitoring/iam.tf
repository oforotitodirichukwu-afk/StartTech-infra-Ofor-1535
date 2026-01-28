# Create IAM Role for EC2
resource "aws_iam_role" "ec2_log_role" {
  name = "ec2_cloudwatch_log_role_v6" 

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })

  lifecycle {
    create_before_destroy = true
  }
}

# Attach Policy to allow writing to CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile to attach to the Launch Template
resource "aws_iam_instance_profile" "ec2_log_profile" {
  name = "ec2_log_profile_v6" 
  role = aws_iam_role.ec2_log_role.name

  # Ensures the role exists before AWS tries to wrap it in a profile
  depends_on = [aws_iam_role.ec2_log_role]
}