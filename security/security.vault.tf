resource "aws_security_group" "boundary_sandcastle" {
  vpc_id = var.network_vpc_id
}
data "http" "get_local_ip" {
  url = "https://ipv4.icanhazip.com"
}
resource "aws_vpc_security_group_ingress_rule" "boundary_sandcastle_ssh" {
  depends_on        = [data.http.get_local_ip]
  security_group_id = aws_security_group.boundary_sandcastle.id
  cidr_ipv4         = "${chomp(data.http.get_local_ip.response_body)}/32"
  from_port         = 22
  ip_protocol       = "tcp"
  to_port           = 22
}
resource "aws_vpc_security_group_egress_rule" "boundary_sandcastle_allow_all" {
  security_group_id = aws_security_group.boundary_sandcastle.id
  cidr_ipv4         = "0.0.0.0/0"
  ip_protocol       = "-1"
}
resource "aws_vpc_security_group_ingress_rule" "boundary_sandcastle_psql_controller" {
  security_group_id = aws_security_group.boundary_sandcastle.id
  referenced_security_group_id = aws_security_group.boundary_sandcastle.id
  from_port         = 5432
  ip_protocol       = "tcp"
  to_port           = 5432
}
resource "aws_vpc_security_group_ingress_rule" "boundary_sandcastle_local_api" {
  depends_on        = [data.http.get_local_ip]
  security_group_id = aws_security_group.boundary_sandcastle.id
  cidr_ipv4         = "${chomp(data.http.get_local_ip.response_body)}/32"
  from_port         = 9200
  ip_protocol       = "tcp"
  to_port           = 9200
}