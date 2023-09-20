#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Remote State
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

#Save remote data to s3 bucket
terraform {
  backend "s3" {
    bucket = "susel-project-network-terraform-state"
    key    = "dev/servers/terraform.tfstate"
    region = "eu-central-1"
  }
}

#-----------------------------

#Get data form remote s3 bucket tfstate file
data "terraform_remote_state" "network" {
  backend = "s3"
  config = {
    bucket = "susel-project-network-terraform-state"
    key    = "dev/network/terraform.tfstate"
    region = "eu-central-1"
  }
}

data "aws_ami" "latest_linux" { #search latest amazon linux2 AMI
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#-----------------------------------


resource "aws_instance" "webserver" {
  ami                    = data.aws_ami.latest_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id]
  subnet_id              = data.terraform_remote_state.network.outputs.public_subnet_ids[0]
  user_data              = filebase64("user_data.sh")
  tags = {
    Name = "${var.env}_server"
  }
}

resource "aws_security_group" "dynamic_sg" {
  name        = "Dynamic SG"
  description = "Dynamic SG"
  vpc_id      = data.terraform_remote_state.network.outputs.vpc_id

  dynamic "ingress" {
    for_each = ["80", "443"] #fill these ports in ingress.value
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
    cidr_blocks = [data.terraform_remote_state.network.outputs.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.env}_server_sg"
    Owner = "Denis Ananev"
  }
}

#-----------------------------------

