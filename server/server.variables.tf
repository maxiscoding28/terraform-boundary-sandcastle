variable "most_recent_ami" { type = bool }
variable "ami_owners" { type = list(string) }
variable "ami_name_filters" { type = list(string) }
variable "subnet_id" { type = string }
variable "security_group" {type = string}
variable "key_name" {
  type = string
}