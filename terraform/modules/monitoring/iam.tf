# Create IAM Role for EC2
resource "aws_iam_role" "ec2_log_role" {
  # Bumping to v5 to ensure a fresh resource name
  name = "ec2_cloudwatch_log_role_v5" 

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
}

# Attach Policy to allow writing to CloudWatch
resource "aws_iam_role_policy_attachment" "cloudwatch_attach" {
  role       = aws_iam_role.ec2_log_role.name
  policy_arn = "arn:aws:iam::aws:policy/CloudWatchAgentServerPolicy"
}

# Instance Profile to attach to the Launch Template
resource "aws_iam_instance_profile" "ec2_log_profile" {
  # This name MUST match exactly in your modules/compute/main.tf
  name = "ec2_log_profile_v5" 
  role = aws_iam_role.ec2_log_role.name
}