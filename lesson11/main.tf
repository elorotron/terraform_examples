#-----------------------------------------------------------------------------------------------------------------
# My Terraform
# Create:
#    - Security Group for Web Server and ALB
#    - Launch Template with Auto AMI Lookup
#    - Auto Scaling Group using 2 Availability Zones
#    - Application Load Balancer in 2 Availability Zones
#    - Application Load Balancer TargetGroup
# Update to Web Servers will be via Green/Blue Deployment Strategy
# Web Server with Zero DownTime and Green/Blue Deployment
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

data "aws_availability_zones" "available_zones" {}

data "aws_ami" "latest_linux" { #search latest amazon linux2 AMI
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#--------Security Group-------------------------------------------------------------------------------------------------------------

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_security_group" "dynamic_sg" {
  name        = "Dynamic SG"
  description = "Dynamic SG"
  vpc_id      = aws_default_vpc.default.id # This need to be added since AWS Provider v4.29+ to set VPC id

  dynamic "ingress" {
    for_each = ["80", "443"] #fill these ports in ingress.value
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

#----Launch configuration----------------------------------------------------------
resource "aws_launch_configuration" "web" {
  #name            = "web-server-LC"
  name_prefix     = "web-server-LC-"
  image_id        = data.aws_ami.latest_linux.id
  instance_type   = "t2.micro"
  security_groups = [aws_security_group.dynamic_sg.id]
  user_data       = file("user_data.sh")

  lifecycle {
    create_before_destroy = true
  }
}

#-----------------------Auto Scaling Group----------------------------------------------------------------------------
resource "aws_autoscaling_group" "aws_asg" {
  name                 = "ASG-${aws_launch_configuration.web.name}"
  launch_configuration = aws_launch_configuration.web.name
  min_size             = 2                                                                      #min instances
  max_size             = 2                                                                      #max instances
  min_elb_capacity     = 2                                                                      #amount when ASG know instances are done
  vpc_zone_identifier  = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id] #in which subnets you may start instances
  health_check_type    = "ELB"                                                                  #EC2(instance status check) or ELB(ping on web page)
  load_balancers       = [aws_elb.web.name]

  dynamic "tag" {
    for_each = {
      Name  = "WebServer_in_ASG"
      Owner = "Denis Ananev"
      #TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

#-----------------AWS ELB-----------------------

resource "aws_elb" "web" {
  name               = "WebServer-ELB"
  availability_zones = [data.aws_availability_zones.available_zones.names[0], data.aws_availability_zones.available_zones.names[1]]
  security_groups    = [aws_security_group.dynamic_sg.id]
  listener {
    lb_port           = 80
    lb_protocol       = "http"
    instance_port     = 80
    instance_protocol = "http"
  }
  health_check {
    healthy_threshold   = 2
    unhealthy_threshold = 2
    timeout             = 3
    target              = "HTTP:80/"
    interval            = 10
  }
  tags = {
    Name = "WebServer-ELB"
  }
}

#----------default subnet to get "id"----------------------------
resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}


#-----------------------------outputs-----------------------------

output "url_loadbalancer_web" {
  value = aws_elb.web.dns_name
}

