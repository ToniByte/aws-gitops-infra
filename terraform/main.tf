terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~> 3.6"
    }
  }
  backend "s3" {
    bucket = "tonibyte-tfstate-089244386830-eu-central-1-an"
    key    = "gitops/terraform.tfstate"
    region = "eu-central-1"
  }
}

provider "aws" {
  region = "eu-central-1"
}

variable "ssh_cidr" {
  description = "ip"
  type        = string
  default     = "0.0.0.0/0"
}

variable "key_name" {
  type    = string
  default = "tonibyte-key"
}

resource "aws_security_group" "web" {
  name        = "tonibyte-gitops-sg"
  description = "SSH from my IP, HTTP/HTTPS public"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "HTTPS"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "tonibyte-gitops-sg"
  }
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"]

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }
}

resource "aws_instance" "gitops" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = "t3.small"
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.web.id]

  root_block_device {
    volume_size = 20
    volume_type = "gp3"
  }

  tags = {
    Name = "tonibyte-gitops-k3s"
  }
}

resource "aws_eip" "gitops" {
  domain = "vpc"
  tags = {
    Name = "tonibyte-gitops-eip"
  }
}

resource "aws_eip_association" "gitops" {
  instance_id   = aws_instance.gitops.id
  allocation_id = aws_eip.gitops.id
}

output "public_ip" {
  value = aws_eip.gitops.public_ip
}

output "instance_id" {
  value = aws_instance.gitops.id
}

############################
# RDS PostgreSQL
############################

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.default.id]
  }
}

resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_db_subnet_group" "app" {
  name       = "tonibyte-db-subnet"
  subnet_ids = data.aws_subnets.default.ids
}

resource "aws_security_group" "rds" {
  name        = "tonibyte-rds-sg"
  description = "PostgreSQL only from app EC2"
  vpc_id      = data.aws_vpc.default.id

  ingress {
    description     = "Postgres from app SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [aws_security_group.web.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_db_instance" "app" {
  identifier        = "tonibyte-app-db"
  engine            = "postgres"
  engine_version    = "16"
  instance_class    = "db.t3.micro"
  allocated_storage = 20
  storage_encrypted = true

  db_name  = "tonibyte"
  username = "tonibyte"
  password = random_password.db.result

  db_subnet_group_name   = aws_db_subnet_group.app.name
  vpc_security_group_ids = [aws_security_group.rds.id]

  publicly_accessible        = false
  backup_retention_period    = 7
  deletion_protection        = false
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
}

resource "aws_secretsmanager_secret" "db" {
  name = "tonibyte/app/db"
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    DB_HOST     = aws_db_instance.app.address
    DB_PORT     = "5432"
    DB_NAME     = "tonibyte"
    DB_USER     = "tonibyte"
    DB_PASSWORD = random_password.db.result
  })
}

output "rds_endpoint" {
  value = aws_db_instance.app.address
}
