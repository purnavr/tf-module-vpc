resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr

  tags = merge(var.tags, { Name = "${var.env}-vpc" })
}

resource "aws_subnet" "public_subnets" {

  vpc_id     = aws_vpc.main.id
  cidr_block = var.cidr_block

  tags = {
    Name = var.name
  }
}

module "public_subnets" {
  source = "./aws_subnet"
  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  name = each.value["name"]
}


