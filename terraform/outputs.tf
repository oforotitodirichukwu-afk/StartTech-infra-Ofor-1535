output "vpc_id" {
  value = module.networking.vpc_id
}

# These are the only things your 'Lite' infra is building now
output "public_ip" {
  value = module.compute.public_ip
}