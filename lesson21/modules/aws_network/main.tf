#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Provision:
#  - VPC
#  - IGW
#  - Public subnets
#  - Privbate subnets
#  - NAT GW for private subnet to give access to internet from Private subnet
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

data "aws_availability_zones" "available_zones" {}

resource "aws_default_vpc" "default" {}

resource "aws_vpc" "main" {
  cidr_block = var.vpc_cidr
  tags = {
    Name = "${var.env}_vpc"
  }
}

resource "aws_internet_gateway" "main" {
  vpc_id = aws_vpc.main.id
  tags = {
    Name = "${var.env}_gw"
  }
}

#-------------Public subnet and routing------------------------

resource "aws_subnet" "public_subnets" {
  count                   = length(var.public_subnet_cidrs)
  vpc_id                  = aws_vpc.main.id
  cidr_block              = element(var.public_subnet_cidrs, count.index)
  availability_zone       = data.aws_availability_zones.available_zones.names[count.index]
  map_public_ip_on_launch = true
  tags = {
    Name = "${var.env}_public_${count.index + 1}"
  }
}

resource "aws_route_table" "public_subnets" {
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.main.id
  }
  tags = {
    Name = "${var.env}_route_public_subnets"
  }
}

resource "aws_route_table_association" "public_routes" {
  count          = length(aws_subnet.public_subnets[*].id)
  route_table_id = aws_route_table.public_subnets.id
  subnet_id      = element(aws_subnet.public_subnets[*].id, count.index)
}

#--------------NAT GWs with Elastic IPs-------------------------------------

resource "aws_eip" "nat_eip" {
  count  = length(var.private_subnet_cidrs)
  domain = "vpc"
  tags = {
    Name = "${var.env}_nat_eip_${count.index + 1}"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  count         = length(var.private_subnet_cidrs)
  allocation_id = aws_eip.nat_eip[count.index].id
  subnet_id     = element(aws_subnet.public_subnets[*].id, count.index)
  tags = {
    Name = "${var.env}_nat_gw_${count.index + 1}"
  }
}

#-------------Private subnets and Routing------------------------

resource "aws_subnet" "private_subnets" {
  count             = length(var.private_subnet_cidrs)
  vpc_id            = aws_vpc.main.id
  cidr_block        = element(var.private_subnet_cidrs, count.index)
  availability_zone = data.aws_availability_zones.available_zones.names[count.index]
  tags = {
    Name = "${var.env}_public_${count.index + 1}"
  }
}

resource "aws_route_table" "private_subnets" {
  count  = length(var.private_subnet_cidrs)
  vpc_id = aws_vpc.main.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw[count.index].id
  }
  tags = {
    Name = "${var.env}_route_private_subnets_${count.index + 1}"
  }
}

resource "aws_route_table_association" "private_routes" {
  count          = length(aws_subnet.private_subnets[*].id)
  route_table_id = aws_route_table.private_subnets[count.index].id
  subnet_id      = element(aws_subnet.private_subnets[*].id, count.index)
}

#---------------------------------
