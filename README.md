# AWS GitOps Infrastructure

<<<<<<< HEAD
A hands-on **DevOps portfolio project** for learning how to build and automate cloud infrastructure on AWS.

The project combines **Terraform, Ansible, GitHub Actions, Kubernetes and Argo CD** into one automated workflow.
=======
Production-style **DevOps portfolio project**: automated AWS infrastructure and GitOps delivery on Kubernetes.

The stack combines **Terraform (modular IaC), Ansible, GitHub Actions, k3s, Argo CD and AWS managed services** into one end-to-end workflow.

---
>>>>>>> 0f5e9eb (refactor(terraform): modular layout with VPC, RDS and Secrets Manager)

## Architecture

```text
GitHub
   |
   v
GitHub Actions
   |
<<<<<<< HEAD
   +--> Terraform --> AWS
   |                  |
   |                  +--> EC2
   |                  +--> RDS PostgreSQL
   |                  +--> Secrets Manager
   |
   +--> Ansible --> k3s
                       |
                       +--> Argo CD
                       +--> cert-manager
```

## Technologies

* **AWS** — cloud infrastructure
* **Terraform** — Infrastructure as Code
* **Ansible** — server configuration
* **GitHub Actions** — CI/CD automation
* **k3s** — Kubernetes cluster
* **Argo CD** — GitOps
* **RDS PostgreSQL** — managed database
* **Secrets Manager** — database credentials

## How It Works

1. Terraform creates the AWS infrastructure.
2. Ansible configures the EC2 server.
3. k3s provides the Kubernetes cluster.
4. Argo CD manages Kubernetes applications using Git.
5. GitHub Actions automates the whole process.

## Project Structure

```text
.github/workflows/   # GitHub Actions
terraform/           # AWS infrastructure
ansible/             # Server and Kubernetes setup
```

## Learning Goals

This project is created as part of my **DevOps learning and portfolio journey**.

The main goals are to practice:

* Infrastructure as Code
* AWS
* Linux
* CI/CD
* Kubernetes
* GitOps
* Automation
* Secrets management

## Status

**Learning project — continuously improving**

Planned improvements include monitoring, security scanning, AWS OIDC, better networking and a complete application deployment through Argo CD.
 
## Author

**ToniByte**

Built for learning, practice and demonstrating practical DevOps skills.
=======
   +--> Terraform (modules)
   |         |
   |         +--> VPC (public/private subnets, IGW, NAT, multi-AZ)
   |         +--> Security Groups
   |         +--> EC2 (Ubuntu + Elastic IP)
   |         +--> RDS PostgreSQL (private subnets)
   |         +--> Secrets Manager (DB credentials)
   |
   +--> Ansible
             |
             +--> k3s
             +--> Argo CD
             +--> cert-manager + Let's Encrypt

             # Network design
```

# Network design

* Custom VPC (10.0.0.0/16) — not the default VPC

* 2 public subnets (different AZs) → EC2, Internet Gateway, NAT
* 2 private subnets (different AZs) → RDS (AZ coverage requirement)
* Route tables: public → IGW, private → NAT Gateway
* Security Group: SSH from allowed CIDR, HTTP/HTTPS public; RDS only from app SG

# Technologies

| Area              | Tools                                                      |
| ----------------- | ---------------------------------------------------------- |
| Cloud             | AWS (VPC, EC2, RDS, Secrets Manager, EIP, NAT)             |
| IaC               | Terraform modules (vpc, security_group, ec2, rds, secrets) |
| Config management | Ansible roles/playbooks                                    |
| CI/CD             | GitHub Actions                                             |
| Kubernetes        | k3s (single-node)                                          |
| GitOps            | Argo CD                                                    |
| TLS               | cert-manager, Let's Encrypt                                |
| Database          | Amazon RDS PostgreSQL 16                                   |
| Secrets           | AWS Secrets Manager                                        |

# Terraform layout (modular)

Root module only composes child modules — no raw resource blocks for infra logic:

```text
terraform/
├── main.tf                 # module "vpc" / "security_group" / "ec2" / "rds" / "secrets"
├── variables.tf
├── outputs.tf
├── providers.tf            # AWS provider + optional S3 backend
├── terraform.tfvars.example
└── modules/
    ├── vpc/                # VPC, subnets (2 AZ), IGW, NAT, route tables
    ├── security_group/     # SSH / HTTP / HTTPS
    ├── ec2/                # Ubuntu AMI, instance, Elastic IP
    ├── rds/                # random_password, DB subnet group, RDS, RDS SG
    └── secrets/            # Secrets Manager secret + version (JSON credentials)
```

## Why modules

* Clear separation: network / security / compute / database / secrets
* Reusable and review-friendly
* Root shows architecture in ~40 lines
* Suitable for multi-env extension later (dev / prod)

# State

Remote state via S3 backend, for example:

```hcl
backend "s3" {
  bucket = "tonibyte-tfstate-..."
  key    = "gitops/terraform.tfstate"
  region = "eu-central-1"
}
```

# How it works

Terraform provisions VPC (multi-AZ), security groups, EC2 + EIP, RDS in private subnets, and stores DB credentials in Secrets Manager.

Ansible connects over SSH to the EC2 public IP and bootstraps the node.

k3s runs as a single-node Kubernetes cluster.

Argo CD is installed and wired to a Git repository for continuous application sync.

cert-manager issues TLS certificates (Let's Encrypt).

GitHub Actions can run terraform apply and Ansible playbooks on push / workflow_dispatch.

# RDS credentials

Password generated by `random_password` (not hardcoded)

Written into RDS and into Secrets Manager as JSON:

```json
{
  "DB_HOST": "...",
  "DB_PORT": "5432",
  "DB_NAME": "tonibyte",
  "DB_USER": "tonibyte",
  "DB_PASSWORD": "..."
}
```

Secret name example:

```text
tonibyte-gitops/app/db
```

Retrieve in Console:

```text
Secrets Manager → Retrieve secret value
```

Or CLI:

```bash
aws secretsmanager get-secret-value --secret-id tonibyte-gitops/app/db
```

# Project structure

```text
.
├── .github/workflows/      # CI/CD (Terraform + Ansible)
├── terraform/              # Modular AWS infrastructure
│   └── modules/
│       ├── vpc/
│       ├── security_group/
│       ├── ec2/
│       ├── rds/
│       └── secrets/
├── ansible/                # k3s, Argo CD, cert-manager
│   ├── inventory/
│   ├── playbooks/
│   └── roles/              # (or playbooks as in original repo)
└── README.md
```

# Quick start

## Prerequisites

* AWS account, IAM credentials, existing EC2 Key Pair
* Terraform >= 1.5
* Ansible
* Optional: S3 bucket for remote state

## Terraform

```bash
cd terraform
cp terraform.tfvars.example terraform.tfvars
```

Set `ssh_cidr = "YOUR_IP/32"` and `key_name`.

```bash
terraform init
terraform plan
terraform apply
```

Useful outputs:

```bash
terraform output public_ip        # SSH target
terraform output rds_endpoint
terraform output secrets_arn
```

## Ansible

After EC2 is up:

```bash
# inventory with public_ip from terraform output
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/bootstrap-k3s.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/install-argocd.yml
ansible-playbook -i ansible/inventory/hosts.ini ansible/playbooks/install-cert-manager.yml
```

# Learning goals / portfolio highlights

| Skill                  | What was implemented                                   |
| ---------------------- | ------------------------------------------------------ |
| Infrastructure as Code | Modular Terraform, remote state                        |
| AWS networking         | Custom VPC, public/private subnets, IGW, NAT, multi-AZ |
| Compute                | EC2, Elastic IP, security groups                       |
| Data                   | RDS PostgreSQL in private subnets                      |
| Secrets management     | Secrets Manager, no password in git                    |
| Linux / config         | Ansible bootstrap of k3s                               |
| Kubernetes / GitOps    | k3s + Argo CD + cert-manager                           |
| CI/CD                  | GitHub Actions automation                              |
| Design                 | Modules, outputs → inputs, least privilege toward RDS  |

# Status

Learning / portfolio project — actively refined.

## Done in this iteration

* [x] Modular Terraform (module composition)
* [x] Custom VPC with internet access (IGW + NAT)
* [x] Multi-AZ subnets for RDS compliance
* [x] EC2 + EIP in public subnet
* [x] RDS in private subnets + Secrets Manager

## Planned

* [ ] AWS OIDC for GitHub Actions (no long-lived keys)
* [ ] Monitoring (Prometheus / Grafana or CloudWatch)
* [ ] Security scanning in CI
* [ ] Full app deploy via Argo CD + External Secrets from Secrets Manager
* [ ] Optional second environment (staging)

# Author

**ToniByte**

Built for learning, practice, and demonstrating practical DevOps skills on AWS.
>>>>>>> 0f5e9eb (refactor(terraform): modular layout with VPC, RDS and Secrets Manager)
