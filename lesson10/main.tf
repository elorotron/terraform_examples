#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Find AMI id
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

data "aws_ami" "latest_ubuntu" { #search latest ubuntu AMI
  owners      = ["099720109477"]
  most_recent = true
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
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

output "latest_AMI_id_ubuntu" {
  value = data.aws_ami.latest_ubuntu.id
}

output "latest_AMI_name_ubuntu" {
  value = data.aws_ami.latest_ubuntu.name
}

output "latest_AMI_id_amazon" {
  value = data.aws_ami.latest_linux.id
}

output "latest_AMI_name_amazon" {
  value = data.aws_ami.latest_linux.name
}
