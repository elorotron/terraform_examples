#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Conditions and Lookups
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

variable "env" {
  default = "prod"
}

variable "ec2_size" {
  default = {
    prod    = "t3.medium"
    dev     = "t2.micro"
    staging = "t2.small"
  }
}

variable "prod_owner" {
  default = "Denis Ananev"
}

variable "dev_owner" {
  default = "Susel"
}

variable "allow_port_list" {
  default = {
    prod = ["80", "443"]
    dev  = ["80", "443", "22", "8080"]
  }
}

resource "aws_instance" "web1" {
  ami = "ami-06fd5f7cfe0604468" #Amazon linux 2
  #instance_type = var.env == "prod" ? "t2.large" : "t2.micro"
  instance_type = var.env == "prod" ? var.ec2_size["prod"] : var.ec2_size["dev"]
  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.dev_owner
  }
}

resource "aws_instance" "dev_bastion" {
  count         = var.env == "dev" ? 1 : 0
  ami           = "ami-06fd5f7cfe0604468" #Amazon linux 2
  instance_type = "t2.micro"

  tags = {
    Name = "Bastion server for DEV"
  }
}

resource "aws_instance" "web2" {
  ami           = "ami-06fd5f7cfe0604468"       #Amazon linux 2
  instance_type = lookup(var.ec2_size, var.env) #lookup(map, key)

  tags = {
    Name  = "${var.env}-server"
    Owner = var.env == "prod" ? var.prod_owner : var.dev_owner
  }
}




#-------Security Group---------

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "dynamic_sg" {
  name        = "Dynamic SG"
  description = "Dynamic SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = lookup(var.allow_port_list, var.env) #fill these ports in ingress.value
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
