#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Build WebServer
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------
provider "aws" {
  region = "eu-central-1"
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "my_webserver" {
  ami                    = "ami-03a71cec707bfc3d7" #Amazon Linux
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.my_webserver.id] #collum 35 aws_security_group.[name of SG]
  user_data = templatefile("./install.sh.tpl", {                #Path to template file
    f_name = "Denis",                                           #Vars
    l_name = "Ananev",                                          #Vars
    names  = ["Roman", "John", "Michael", "Olga"]               #Vars
  })
  user_data_replace_on_change = true #recreate instance for apply changes in static file (./install.sh)

  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Denis Ananev"
  }
}


resource "aws_security_group" "my_webserver" {
  name        = "WebServer SG"
  description = "My First SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "Web Server SG"
    Owner = "Denis Ananev"
  }
}
