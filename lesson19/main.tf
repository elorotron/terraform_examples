#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Provision Resources in Multiply AWS Regions / Accounts
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
  #Two ways to use multiply accounts: Assume role or access and secret key
  //access_key = "XXXXXXXXXXXXXXXXXXXXXXX"
  //secret_key = "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"
  //assume_role {
  //  role_arn     = "arn:aws:iam::1234567890:role/RemoteAdministrators"
  //  session_name = "TERRAFROM_SESSION"
  //}
}



provider "aws" {
  region = "us-east-1"
  alias  = "USA"
}

provider "aws" {
  region = "eu-west-2"
  alias  = "LONDON"
}

#=================================================

data "aws_ami" "default_latest_amazon_linux" {
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "usa_latest_amazon_linux" {
  provider    = aws.USA
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

data "aws_ami" "london_latest_amazon_linux" {
  provider    = aws.LONDON
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}


resource "aws_instance" "default_server" {
  instance_type = "t2.micro"
  ami           = data.aws_ami.default_latest_amazon_linux.id #Amazon linux 2
  tags = {
    Name = "Default server"
  }
}

resource "aws_instance" "usa_server" {
  provider      = aws.USA
  instance_type = "t2.micro"
  ami           = data.aws_ami.usa_latest_amazon_linux.id #Amazon linux 2
  tags = {
    Name = "USA Server"
  }
}

resource "aws_instance" "LONDON_server" {
  provider      = aws.LONDON
  instance_type = "t2.micro"
  ami           = data.aws_ami.london_latest_amazon_linux.id #Amazon linux 2
  tags = {
    Name = "London Server"
  }
}


