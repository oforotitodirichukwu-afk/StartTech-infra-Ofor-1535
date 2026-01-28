output "log_group_name" {
  value = aws_cloudwatch_log_group.backend_logs.name
}

output "instance_profile_name" {
  value = aws_iam_instance_profile.ec2_log_profile.name
}