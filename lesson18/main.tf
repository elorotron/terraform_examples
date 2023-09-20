#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Terraform loops: Count, for if
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}


#-----------Create users-------------------------------



resource "aws_iam_user" "user1" {
  name = "leskis"
}

resource "aws_iam_user" "iam_users" {
  count = length(var.aws_users)
  name  = element(var.aws_users, count.index)
}

#------------EC2-instance---------------------------

resource "aws_instance" "servers" {
  ami           = "ami-06fd5f7cfe0604468" #Amazon linux 2
  instance_type = "t2.micro"
  count         = 3
  tags = {
    Name = "Sever_number_${count.index + 1}"
  }
}
