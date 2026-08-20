terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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
