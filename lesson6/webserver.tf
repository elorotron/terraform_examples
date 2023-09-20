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

resource "aws_eip" "static_ip" {
  instance = aws_instance.my_webserver.id #attache elastic ip (static ip) to instance
}

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_instance" "my_webserver" {
  ami                    = "ami-03a71cec707bfc3d7" #Amazon Linux
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id] # aws_security_group.[name of SG]
  user_data = templatefile("./install.sh.tpl", {              #Path to template file
    f_name = "Denis",                                         #Vars
    l_name = "Ananev",                                        #Vars
    names  = ["Roman", "John", "Michael", "Olga", "xz"]       #Vars
  })
  user_data_replace_on_change = true #recreate instance for apply changes in static file (./install.sh)

  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Denis Ananev"
  }

  lifecycle {
    #prevent_destroy = true #blocking to destroy
    #ignore_changes = ["ami", "user_data"] #ignore changes in these scope and skip it
    #create_before_destroy = true #reduce downtime, create new instance before killind old instance
  }
}

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
