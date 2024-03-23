resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    var.tags,
    { Name = "${var.env}-vpc" }
  )
}

## public_subnets
resource "aws_subnet" "public_subnets" {
  vpc_id     = aws_vpc.main.id

  for_each = var.public_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

# Internet_Gateway
resource "aws_internet_gateway" "igw" {
  vpc_id = aws_vpc.main.id

  tags = merge(
    var.tags,
    { Name = "${var.env}-igw" }
  )
}

# Nat Gateway

resource "aws_eip" "nat" {
  for_each = var.public_subnets
  domain   = "vpc"
}

resource "aws_nat_gateway" "nat-gatways" {
  for_each = var.public_subnets
  allocation_id = aws_eip.nat[each.value["name"]].id
  subnet_id     = aws_subnet.public_subnets[each.value["name"]].id

  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

## public_route table
resource "aws_route_table" "public_route_tables" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

## public_association
resource "aws_route_table_association" "public_association" {
  for_each = var.public_subnets
  #subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null), "id", null)
  subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
  route_table_id = aws_route_table.public_route_tables[each.value["name"]].id
}

## private_subnets
resource "aws_subnet" "private_subnets" {
  vpc_id     = aws_vpc.main.id

  for_each = var.private_subnets
  cidr_block = each.value["cidr_block"]
  availability_zone = each.value["availability_zone"]

  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

## private_route table
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.main.id

  for_each = var.private_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

## private_association
resource "aws_route_table_association" "private_association" {
  for_each = var.private_subnets
  #subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null), "id", null)
  subnet_id      = aws_subnet.private_subnets[each.value["name"]].id
  route_table_id = aws_route_table.private_route_tables[each.value["name"]].id
}

