resource "aws_launch_template" "backend" {
  image_id      = "ami-0e2c8ccd4e022268b" # Ubuntu 22.04 LTS in us-east-1
  instance_type = "t2.micro"
  # ... rest of your code

  network_interfaces {
    associate_public_ip_address = true
    security_groups             = [var.backend_sg_id]
  }

  # This script runs when the server starts
  user_data = base64encode(<<-EOF
              #!/bin/bash
              sudo yum update -y
              sudo amazon-linux-extras install docker -y
              sudo service docker start
              sudo usermod -a -G docker ec2-user
              EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = { Name = "starttech-backend-node" }
  }
}

# 2. Auto Scaling Group (Ensures you always have 2 servers running)
resource "aws_autoscaling_group" "backend_asg" {
  desired_capacity    = 2
  max_size            = 3
  min_size            = 1
  vpc_zone_identifier = var.public_subnet_ids
#  target_group_arns   = [aws_lb_target_group.backend_tg.arn]

  launch_template {
    id      = aws_launch_template.backend.id
    version = "$Latest"
  }
}

# 3. Application Load Balancer (Distributes traffic to servers)
#e "aws_lb" "backend_alb" {
 # name               = "backend-alb"
  #internal           = false
  #load_balancer_type = "application"
  #security_groups    = [var.alb_sg_id]
  #subnets            = var.public_subnet_ids
#}

# 4. Target Group (The list of servers the ALB talks to)
#resource "aws_lb_target_group" "backend_tg" {
 # name     = "backend-target-group"
  #port     = 8080
  #protocol = "HTTP"
  #vpc_id   = var.vpc_id

  #health_check {
   # path = "/health" # Matches your Go backend health endpoint
  #}
#}

# 5. ALB Listener (Forwards web traffic to the target group)
#resource "aws_lb_listener" "front_end" {
 # load_balancer_arn = aws_lb.backend_alb.arn
  #port              = "80"
  #protocol          = "HTTP"

  #default_action {
   # type             = "forward"
    #target_group_arn = aws_lb_target_group.backend_tg.arn
  #}
#}