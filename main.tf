resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

#  tags = {
#    Name = "${var.env}-vpc"
}

#resource "aws_subnet" "main" {
#  vpc_id     = aws_vpc.main.id
#  cidr_block = "var.cidr_block
#
#  tags = {
#    Name = "Main"
#  }
#}