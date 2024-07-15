data "aws_ami" "boundary_sandcastle" {
  most_recent = var.most_recent_ami
  owners      = var.ami_owners
  filter {
    name   = "name"
    values = var.ami_name_filters
  }
}
resource "aws_instance" "boundary_postgresql" {
  ami                    = data.aws_ami.boundary_sandcastle.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags = { Name = "boundary_postgresql" }
  user_data = base64encode(templatefile("${path.module}/bootstrap-pgsql.sh", {}))
}
resource "aws_instance" "boundary_controller" {
  depends_on             = [aws_instance.boundary_postgresql]
  ami                    = data.aws_ami.boundary_sandcastle.id
  instance_type          = "t3.micro"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags = { Name = "boundary_controller" }
  user_data = base64encode(templatefile("${path.module}/bootstrap-controller.sh", {
    boundary_version = var.boundary_version
    boundary_license = var.boundary_license
    postgresql_ip = aws_instance.boundary_postgresql.private_ip
  }))
}