resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr_block

  tags = merge(
    var.tags,
    { Name = "${var.env}-vpc" }
  )
}

## Peering connections
resource "aws_vpc_peering_connection" "peer" {
  peer_owner_id = data.aws_caller_identity.account.account_id
  peer_vpc_id   = var.default_vpc_id
  vpc_id        = aws_vpc.main.id
  auto_accept = true

  tags = merge(
    var.tags,
    { Name = "${var.env}-peer" }
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

  route {
    cidr_block = data.aws_vpc.default_vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
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

#locals {
#  az = split("-", "web-az1")[1]
#}

## private_route table
resource "aws_route_table" "private_route_tables" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.nat-gatways["public-${split("-",each.value["name"])[1]}"].id
  }

  route {
    cidr_block = data.aws_vpc.default_vpc.cidr_block
    vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
  }

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

## default vpc to vpc peering
resource "aws_route" "route" {
  route_table_id              = var.default_route_table
  destination_cidr_block = var.vpc_cidr_block
  vpc_peering_connection_id = aws_vpc_peering_connection.peer.id
}

