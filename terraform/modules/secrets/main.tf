resource "aws_secretsmanager_secret" "db" {
  name = "${var.name}/app/db"
  tags = var.tags
}
resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    DB_HOST     = var.db_host
    DB_PORT     = tostring(var.db_port)
    DB_NAME     = var.db_name
    DB_USER     = var.db_username
    DB_PASSWORD = var.db_password
  })
}
