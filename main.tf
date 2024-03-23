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

## public_route table
resource "aws_route_table" "public_route_tables" {
  vpc_id = aws_vpc.main.id

  for_each = var.public_subnets
  tags = merge(
    var.tags,
    { Name = "${var.env}-${each.value["name"]}" }
  )
}

resource "aws_route_table_association" "public_association" {
  for_each = var.public_subnets
  subnet_id      = lookup(lookup(aws_subnet.public_subnets, each.value["name"], null), "id", null)
  #subnet_id      = aws_subnet.public_subnets[each.value["name"]].id
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