variable "name" { type = string }
variable "instance_type" {
  type    = string
  default = "t3.small"
}
variable "key_name" { type = string }
variable "subnet_id" { type = string }
variable "security_group_ids" { type = list(string) }
variable "internet_gateway_id" {
  type    = string
  default = ""
}
variable "root_volume_size" {
  type    = number
  default = 20
}
variable "tags" {
  type    = map(string)
  default = {}
}
