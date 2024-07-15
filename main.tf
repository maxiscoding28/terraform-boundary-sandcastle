module "network" {
  source                  = "./network"
  vpc_cidr_block          = var.vpc_cidr_block
  enable_dns_hostnames    = var.enable_dns_hostnames
  subnet_a_cidr_block     = var.subnet_a_cidr_block
  subnet_b_cidr_block     = var.subnet_b_cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
}
module "security" {
  source         = "./security"
  network_vpc_id = module.network.vpc_id
}
module "server" {
  source           = "./server"
  most_recent_ami  = var.most_recent_ami
  ami_owners       = var.ami_owners
  ami_name_filters = var.ami_name_filters
  subnet_id        = module.network.subnets[0]
  security_group   = module.security.security_group_id
  key_name         = var.ec2_key_pair_name
  boundary_version = var.boundary_version
  boundary_license = var.boundary_license
}