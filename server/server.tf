data "aws_ami" "boundary_sandcastle" {
  most_recent = var.most_recent_ami
  owners      = var.ami_owners
  filter {
    name   = "name"
    values = var.ami_name_filters
  }
}
resource "aws_instance" "boundary_controller" {
  ami           = data.aws_ami.boundary_sandcastle.id
  instance_type = "t3.micro"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [var.security_group]
    key_name = var.key_name
  tags = {
    Name = "boundary_controller"
  }
}
resource "aws_instance" "postgres_for_controller" {
  ami           = data.aws_ami.boundary_sandcastle.id
  instance_type = "t3.micro"
    subnet_id = var.subnet_id
    vpc_security_group_ids = [var.security_group]
    key_name = var.key_name
  tags = {
    Name = "postgres_for_controller"
  }
}