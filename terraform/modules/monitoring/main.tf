# 1. CloudWatch Log Group for Backend Application Logs
resource "aws_cloudwatch_log_group" "backend_logs" {
  # Bumping to v6 to avoid "ResourceAlreadyExistsException"
  name              = "/aws/starttech/backend-logs-v6"
  retention_in_days = 7
  
  tags = { 
    Name    = "BackendLogs-v6"
    Project = "StartTech"
  }
}

# 2. CloudWatch Metric Alarm (Alerts if CPU is too high)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  # Bumping to v6 for a fresh, unique alarm name
  alarm_name          = "high-cpu-usage-v6"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization for the v6 cluster"

  # Ties this alarm to your specific Auto Scaling Group
  dimensions = {
    AutoScalingGroupName = "backend-asg-v6"
  }
}