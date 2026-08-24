variable "name" { type = string }
variable "vpc_id" { type = string }
variable "subnet_ids" { type = list(string) }
variable "app_security_group_id" { type = string }
variable "db_name" {
  type    = string
  default = "tonibyte"
}
variable "db_username" {
  type    = string
  default = "tonibyte"
}
variable "instance_class" {
  type    = string
  default = "db.t3.micro"
}
variable "tags" {
  type    = map(string)
  default = {}
}
