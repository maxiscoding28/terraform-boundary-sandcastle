variable "vpc_cidr_block" {
  type    = string
  default = "10.0.0.0/16"
}
variable "enable_dns_hostnames" {
  type    = bool
  default = true
}
variable "subnet_a_cidr_block" {
  type    = string
  default = "10.0.1.0/24"
}
variable "subnet_b_cidr_block" {
  type    = string
  default = "10.0.2.0/24"
}
variable "map_public_ip_on_launch" {
  type    = bool
  default = true
}
variable "most_recent_ami" {
  type    = bool
  default = true
}
variable "ami_owners" {
  type    = list(string)
  default = ["amazon"]
}
variable "ami_name_filters" {
  type    = list(string)
  default = ["al2023-ami-2023.4.20240611.0-kernel-6.1-x86_64"]
}
variable "ec2_key_pair_name" {
  type    = string
  default = ""
}