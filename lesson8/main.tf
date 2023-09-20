#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Create aws instance with Security Group (SG)
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
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id] # aws_security_group.[name of SG]

  tags = {
    Name  = "Web Server Build by Terraform"
    Owner = "Denis Ananev"
  }
  depends_on = [aws_instance.my_sql, aws_instance.my_app] #instance will be created after starting these 2 instances 
}

resource "aws_instance" "my_sql" {
  ami                    = "ami-03a71cec707bfc3d7" #Amazon Linux
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id] # aws_security_group.[name of SG]

  tags = {
    Name  = "SQL Server Build by Terraform"
    Owner = "Denis Ananev"
  }
}

resource "aws_instance" "my_app" {
  ami                    = "ami-03a71cec707bfc3d7" #Amazon Linux
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id] # aws_security_group.[name of SG]

  tags = {
    Name  = "APP Server Build by Terraform"
    Owner = "Denis Ananev"
  }
  depends_on = [aws_instance.my_sql] #instance will be created after starting this instance (my_sql)
}

resource "aws_security_group" "dynamic_sg" {
  name   = "Dynamic SG"
  vpc_id = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443", "22"] #fill these ports in ingress.value
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

  tags = {
    Name  = "Dynamic SG"
    Owner = "Denis Ananev"
  }
}
