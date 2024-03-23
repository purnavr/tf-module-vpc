resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.main.id
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]

  tags = {
    Name = each.value["name"]
  }
}

