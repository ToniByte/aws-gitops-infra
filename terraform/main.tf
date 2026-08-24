locals {
  tags = {
    Project   = var.project_name
    ManagedBy = "terraform"
  }
}

module "vpc" {
  source               = "./modules/vpc"
  name                 = var.project_name
  cidr_block           = var.vpc_cidr
  public_subnet_cidrs  = var.public_subnet_cidrs
  private_subnet_cidrs = var.private_subnet_cidrs
  tags                 = local.tags
}

module "security_group" {
  source   = "./modules/security_group"
  name     = var.project_name
  vpc_id   = module.vpc.vpc_id
  ssh_cidr = var.ssh_cidr
  tags     = local.tags
}

module "ec2" {
  source              = "./modules/ec2"
  name                = "${var.project_name}-k3s"
  instance_type       = var.instance_type
  key_name            = var.key_name
  subnet_id           = module.vpc.public_subnet_ids[0]
  security_group_ids  = [module.security_group.security_group_id]
  internet_gateway_id = module.vpc.internet_gateway_id
  root_volume_size    = var.root_volume_size
  tags                = local.tags
}

module "rds" {
  source                = "./modules/rds"
  name                  = var.project_name
  vpc_id                = module.vpc.vpc_id
  subnet_ids            = module.vpc.private_subnet_ids
  app_security_group_id = module.security_group.security_group_id
  db_name               = var.db_name
  db_username           = var.db_username
  instance_class        = var.db_instance_class
  tags                  = local.tags
}

module "secrets" {
  source      = "./modules/secrets"
  name        = var.project_name
  db_host     = module.rds.address
  db_port     = module.rds.port
  db_name     = module.rds.db_name
  db_username = module.rds.username
  db_password = module.rds.password
  tags        = local.tags
}
