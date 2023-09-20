#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Get data
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {}

data "aws_availability_zones" "zones" {}
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}
data "aws_vpcs" "current" {}
data "aws_vpc" "default" {
  tags = {
    Name = "default"
  }
}


resource "aws_subnet" "prod_subnet_1" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = data.aws_availability_zones.zones.names[0]
  cidr_block        = "10.0.1.0/24"
  tags = {
    Name    = "Subnet-1 in ${data.aws_availability_zones.zones.names[0]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = "Region in ${data.aws_region.current.description}"
  }
}

resource "aws_subnet" "prod_subnet_2" {
  vpc_id            = data.aws_vpc.default.id
  availability_zone = data.aws_availability_zones.zones.names[1]
  cidr_block        = "10.0.2.0/24"
  tags = {
    Name    = "Subnet-2 in ${data.aws_availability_zones.zones.names[1]}"
    Account = "Subnet in Account ${data.aws_caller_identity.current.account_id}"
    Region  = "Region in ${data.aws_region.current.description}"
  }
}









output "data_aws_availability_zones" {
  value = data.aws_availability_zones.zones.names[1]
}

output "account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "user_id" {
  value = data.aws_caller_identity.current.user_id
}

output "aws_region_name" {
  value = data.aws_region.current.name
}

output "aws_region_description" {
  value = data.aws_region.current.description
}

output "aws_vpcs" {
  value = data.aws_vpcs.current.ids
}

output "aws_vpc_id" {
  value = data.aws_vpc.default.id
}

output "aws_vpc_cidr_block" {
  value = data.aws_vpc.default.cidr_block
}
