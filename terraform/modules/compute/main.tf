# 1. Launch Template (Defines the EC2 Blueprint)
resource "aws_launch_template" "backend" {
  image_id      = "ami-0c7217cdde317cfec" # Swapped to a verified Ubuntu 22.04 AMI for us-east-1
  instance_type = "t2.micro"

  iam_instance_profile {
    # Updated to v5 to match iam.tf and avoid 'AlreadyExists' conflicts
    name = "ec2_log_profile_v5" 
  }

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.backend_sg_id]
  }

  # This script installs Docker and runs your specific Go container
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo apt-get update -y
              sudo apt-get install -y docker.io
              sudo systemctl start docker
              sudo systemctl enable docker
              
              # Allow the ubuntu user to run docker commands
              sudo usermod -a -G docker ubuntu

              # Pull and run your backend container
              # Mapping port 80 on the host to 8080 in your Go app
              sudo docker run -d --restart always -p 80:8080 --name backend princep260471/starttech-backend:latest
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "starttech-backend-node-v5" }
  }
}

# 2. Auto Scaling Group (Ensures high availability)
resource "aws_autoscaling_group" "backend_asg" {
  # Naming the ASG explicitly to avoid collisions
  name                = "backend-asg-v5"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}