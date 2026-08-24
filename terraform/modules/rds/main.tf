resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}
resource "aws_db_subnet_group" "this" {
  name       = "${var.name}-db-subnet"
  subnet_ids = var.subnet_ids
  tags       = merge(var.tags, { Name = "${var.name}-db-subnet" })
}
resource "aws_security_group" "rds" {
  name        = "${var.name}-rds-sg"
  description = "PostgreSQL only from app SG"
  vpc_id      = var.vpc_id
  ingress {
    description     = "Postgres from app SG"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [var.app_security_group_id]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
  tags = merge(var.tags, { Name = "${var.name}-rds-sg" })
}
resource "aws_db_instance" "this" {
  identifier                 = "${var.name}-app-db"
  engine                     = "postgres"
  engine_version             = "16"
  instance_class             = var.instance_class
  allocated_storage          = 20
  storage_encrypted          = true
  db_name                    = var.db_name
  username                   = var.db_username
  password                   = random_password.db.result
  db_subnet_group_name       = aws_db_subnet_group.this.name
  vpc_security_group_ids     = [aws_security_group.rds.id]
  publicly_accessible        = false
  backup_retention_period    = 0
  deletion_protection        = false
  skip_final_snapshot        = true
  auto_minor_version_upgrade = true
  tags = merge(var.tags, { Name = "${var.name}-app-db" })
}
