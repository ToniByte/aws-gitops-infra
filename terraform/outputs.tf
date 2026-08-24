output "vpc_id" { value = module.vpc.vpc_id }
output "public_subnet_ids" { value = module.vpc.public_subnet_ids }
output "private_subnet_ids" { value = module.vpc.private_subnet_ids }
output "public_ip" { value = module.ec2.public_ip }
output "instance_id" { value = module.ec2.instance_id }
output "rds_endpoint" { value = module.rds.address }
output "secrets_arn" { value = module.secrets.secret_arn }
