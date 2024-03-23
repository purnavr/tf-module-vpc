resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = {
    Name = merge(
      var.tags
      "${var.env}-vpc")
  }
}

resource "aws_subnet" "main" {
  vpc_id     = aws_vpc.main.id
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = {
    Name = merge(
      var.tags
      "${var.env}-${each.value[name]}")
  }
}