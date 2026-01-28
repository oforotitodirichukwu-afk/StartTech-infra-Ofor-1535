# This tells Terraform where to find the Networking logic
module "networking" {
  source = "./modules/networking"
}

# This tells Terraform where to find the Storage logic
#module "storage" {
 # source     = "./modules/storage"
#  student_id = "1535" # Your ID
#}

# This tells Terraform where to find the Monitoring logic
module "monitoring" {
  source = "./modules/monitoring"
}

# This tells Terraform where to find the Compute logic
module "compute" {
  source            = "./modules/compute"
  vpc_id            = module.networking.vpc_id
  public_subnet_ids = module.networking.public_subnet_ids
  alb_sg_id         = module.networking.backend_sg_id
  backend_sg_id     = module.networking.backend_sg_id
}