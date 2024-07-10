output "vpc_id" {
  value = aws_vpc.boundary_sandcastle.id
}
output "subnets" {
  value = [aws_subnet.boundary_sandcastle_a.id, aws_subnet.boundary_sandcastle_b.id]
}