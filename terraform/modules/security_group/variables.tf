variable "name" { type = string }
variable "description" {
  type    = string
  default = "SSH + HTTP/HTTPS"
}
variable "vpc_id" { type = string }
variable "ssh_cidr" { type = string }
variable "tags" {
  type    = map(string)
  default = {}
}
