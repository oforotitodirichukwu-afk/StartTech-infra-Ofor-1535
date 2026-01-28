# 1. CloudWatch Log Group for Backend Application Logs
resource "aws_cloudwatch_log_group" "backend_logs" {
  # Updated to v4 to resolve naming conflicts from previous failed runs
  name              = "/aws/starttech/backend-logs-v4"
  retention_in_days = 7
  tags              = { Name = "BackendLogs" }
}

# 2. CloudWatch Metric Alarm (Alerts if CPU is too high)
resource "aws_cloudwatch_metric_alarm" "high_cpu" {
  # Updated to v4 to ensure this resource is fresh and unique
  alarm_name          = "high-cpu-usage-v4"
  comparison_operator = "GreaterThanThreshold"
  evaluation_periods  = "2"
  metric_name         = "CPUUtilization"
  namespace           = "AWS/EC2"
  period              = "120"
  statistic           = "Average"
  threshold           = "80"
  alarm_description   = "This metric monitors ec2 cpu utilization"
}