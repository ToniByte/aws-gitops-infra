variable "aws_region" {
  type    = string
  default = "eu-central-1"
}

variable "project_name" {
  type    = string
  default = "tonibyte-gitops"
}

variable "vpc_cidr" {
  type    = string
  default = "10.0.0.0/16"
}

variable "public_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  type    = list(string)
  default = ["10.0.11.0/24", "10.0.12.0/24"]
}

variable "ssh_cidr" {
  type = string
}

variable "key_name" {
  type    = string
  default = "tonibyte-key"
}

variable "instance_type" {
  type    = string
  default = "t3.small"
}

variable "root_volume_size" {
  type    = number
  default = 20
}

variable "db_name" {
  type    = string
  default = "tonibyte"
}

variable "db_username" {
  type    = string
  default = "tonibyte"
}

variable "db_instance_class" {
  type    = string
  default = "db.t3.micro"
}
