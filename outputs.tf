output "public_subnets" {
  value = aws_subnet.public_subnets
}

output "nat" {
  value = aws_nat_gateway.nat-gatways
}