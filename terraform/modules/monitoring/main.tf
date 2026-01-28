# 1. CloudWatch Log Group for Backend Application Logs
resource "aws_cloudwatch_log_group" "backend_logs" {
  # Added _v2 to the name to bypass the "Already Exists" error
  name              = "/aws/starttech/backend-logs-v2"
  retention_in_days = 7
  tags              = { Name = "BackendLogs" }
}

# 2. CloudWatch Metric Alarm (Alerts if CPU is too high)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  # Added _v2 here as well to ensure this resource is fresh
  alarm_name          = "high-cpu-usage-v2"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
}