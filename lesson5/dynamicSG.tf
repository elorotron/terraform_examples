#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Build Dynamic SG
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "dynamic_sg" {
  name        = "Dynamic SG"
  description = "Dynamic SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "8080", "1541", "9092"] #fill these ports in ingress.value
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }


  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["10.10.0.0/16"] #open only for this local subnet
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Dynamic SG"
    Owner = "Denis Ananev"
  }
}
