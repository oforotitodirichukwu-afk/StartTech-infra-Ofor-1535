output "vpc_id" {
  value = aws_vpc.main.id
}

output "public_subnet_ids" {
  value = aws_subnet.public[*].id
}
output "backend_sg_id" {
  description = "The ID of the security group for the backend"
  value       = aws_security_group.alb_sg.id 
}