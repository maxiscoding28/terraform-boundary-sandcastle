resource "aws_vpc" "boundary_sandcastle" {
  cidr_block           = var.vpc_cidr_block
  enable_dns_hostnames = var.enable_dns_hostnames
}
data "external" "get_aws_region" {
  program = ["bash", "${path.module}/get_aws_region.sh"]
}
resource "aws_subnet" "boundary_sandcastle_a" {
  vpc_id                  = aws_vpc.boundary_sandcastle.id
  cidr_block              = var.subnet_a_cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "${data.external.get_aws_region.result.region}a"
}
resource "aws_subnet" "boundary_sandcastle_b" {
  vpc_id                  = aws_vpc.boundary_sandcastle.id
  cidr_block              = var.subnet_b_cidr_block
  map_public_ip_on_launch = var.map_public_ip_on_launch
  availability_zone       = "${data.external.get_aws_region.result.region}b"

}
resource "aws_route_table_association" "boundary_sandcastle_a" {
  subnet_id      = aws_subnet.boundary_sandcastle_a.id
  route_table_id = aws_vpc.boundary_sandcastle.main_route_table_id
}
resource "aws_route_table_association" "boundary_sandcastle_b" {
  subnet_id      = aws_subnet.boundary_sandcastle_b.id
  route_table_id = aws_vpc.boundary_sandcastle.main_route_table_id
}
resource "aws_internet_gateway" "boundary_sandcastle" {
  vpc_id = aws_vpc.boundary_sandcastle.id
}
resource "aws_route" "boundary_sandcastle" {
  route_table_id         = aws_vpc.boundary_sandcastle.main_route_table_id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.boundary_sandcastle.id
}