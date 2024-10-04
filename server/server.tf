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
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags                   = { Name = "boundary_postgresql" }
  user_data              = base64encode(templatefile("${path.module}/bootstrap-pgsql.sh", {}))
}
resource "aws_instance" "boundary_controller" {
  depends_on             = [aws_instance.boundary_postgresql]
  ami                    = data.aws_ami.boundary_sandcastle.id
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags                   = { Name = "boundary_controller" }
  user_data = base64encode(templatefile("${path.module}/bootstrap-controller.sh", {
    boundary_version = var.boundary_version
    boundary_license = var.boundary_license
    postgresql_ip    = aws_instance.boundary_postgresql.private_ip
  }))
}
resource "aws_instance" "boundary_worker" {
  depends_on             = [aws_instance.boundary_controller]
  ami                    = data.aws_ami.boundary_sandcastle.id
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags                   = { Name = "boundary_worker" }
  user_data = base64encode(templatefile("${path.module}/bootstrap-worker.sh", {
    boundary_controller_ip = aws_instance.boundary_controller.private_ip
    boundary_version       = var.boundary_version
  }))
}
resource "aws_instance" "boundary_target" {
  depends_on             = [aws_instance.boundary_worker]
  ami                    = data.aws_ami.boundary_sandcastle.id
  instance_type          = "t2.small"
  subnet_id              = var.subnet_id
  vpc_security_group_ids = [var.security_group]
  key_name               = var.key_name
  tags                   = { Name = "boundary_target" }
  user_data = base64encode(templatefile("${path.module}/bootstrap-target.sh", {}))
}

# Target Instance
# Connect over SSH
# Connect over PSQL
# Connect over HTTP