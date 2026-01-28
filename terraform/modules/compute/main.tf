# 1. Launch Template (Defines the EC2 Blueprint)
resource "aws_launch_template" "backend" {
  image_id      = "ami-0c7217cdde317cfec" # Verified Ubuntu 22.04 AMI for us-east-1
  instance_type = "t2.micro"

  iam_instance_profile {
    # Synchronized to v6 to match iam.tf
    name = "ec2_log_profile_v6" 
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
    # Tagging with v6 for clear identification in the console
    tags = { Name = "starttech-backend-node-v6" }
  }
}

# 2. Auto Scaling Group (Ensures high availability)
resource "aws_autoscaling_group" "backend_asg" {
  # Explicit name change to v6 to force a fresh resource creation
  name                = "backend-asg-v6"
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }

  # Tag the instances created by the ASG
  tag {
    key                 = "Name"
    value               = "starttech-backend-asg-v6"
    propagate_at_launch = true
  }
}