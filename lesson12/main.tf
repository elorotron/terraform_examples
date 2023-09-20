#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Variables
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = var.region

  default_tags {
    tags = var.common_tags
  }
}

#---------Find latest amazon linux ami---------------

data "aws_ami" "latest_linux" { #search latest amazon linux2 AMI
  owners      = ["137112412989"]
  most_recent = var.enable_to_find_latest_ami
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#-------------AWS INSTANCE----------------

resource "aws_instance" "my_app" {
  ami                    = data.aws_ami.latest_linux.id #Amazon Linux
  instance_type          = var.instance_type
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id] # aws_security_group.[name of SG]

  tags = merge(var.common_tags, { Name = "${var.common_tags["Name"]} Server IP" })
}

#-------Security Group------------------------

resource "aws_default_vpc" "default" {}

resource "aws_security_group" "dynamic_sg" {
  name        = "Dynamic SG"
  description = "Dynamic SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = var.allowed_ports #fill these ports in ingress.value
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(var.common_tags, { Name = "${var.common_tags["Name"]} Security group" })
}
