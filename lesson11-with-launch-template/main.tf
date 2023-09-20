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

#----------Configure provider-------------------

provider "aws" {
  region = "eu-central-1"

  default_tags {
    tags = {
      Owner     = "Denis Ananev"
      CreatedBy = "Terraform"
      Course    = "ADV-IT Lessons terraform"
    }
  }
}

#----------Data source-------------------------

data "aws_availability_zones" "available_zones" {}

#--------Find latest amazon linux AMI------------

data "aws_ami" "latest_linux" { #search latest amazon linux2 AMI
  owners      = ["137112412989"]
  most_recent = true
  filter {
    name   = "name"
    values = ["amzn2-ami-kernel-5.10-hvm-*-x86_64-gp2"]
  }
}

#---------Availability zones-------------------------

resource "aws_default_vpc" "default" {} # This need to be added since AWS Provider v4.29+ to get VPC id

resource "aws_default_subnet" "default_az1" {
  availability_zone = data.aws_availability_zones.available_zones.names[0]
}

resource "aws_default_subnet" "default_az2" {
  availability_zone = data.aws_availability_zones.available_zones.names[1]
}

#-------Security Group--------------------------

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

#--------Launch Template--------------

resource "aws_launch_template" "web_template" {
  name                   = "WebServer"
  image_id               = data.aws_ami.latest_linux.id
  instance_type          = "t2.micro"
  vpc_security_group_ids = [aws_security_group.dynamic_sg.id]
  user_data              = filebase64("${path.module}/user_data.sh")
}

#-----Auto Scaling Group------------------

resource "aws_autoscaling_group" "aws_asg" {
  name                = "ASG-${aws_launch_template.web_template.latest_version}"
  min_size            = 2                                                                      #min instances
  max_size            = 2                                                                      #max instances
  min_elb_capacity    = 2                                                                      #amount when ASG know instances are done
  vpc_zone_identifier = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id] #in which subnets you may start instances
  health_check_type   = "ELB"                                                                  #EC2(instance status check) or ELB(ping on web page)
  target_group_arns   = [aws_lb_target_group.web_server_lb_tg.arn]

  launch_template {
    id      = aws_launch_template.web_template.id
    version = aws_launch_template.web_template.latest_version
  }

  dynamic "tag" {
    for_each = {
      Name = "WebServer-in-ASG-ver.${aws_launch_template.web_template.latest_version}"
      #TAGKEY = "TAGVALUE"
    }
    content {
      key                 = tag.key
      value               = tag.value
      propagate_at_launch = true
    }
  }

  lifecycle { #Create new server before killing old server
    create_before_destroy = true
  }
}

#---------------AWS Load Balancer------------------------

resource "aws_lb" "web_server_lb" {
  name               = "WebServer-ALB"
  load_balancer_type = "application"
  security_groups    = [aws_security_group.dynamic_sg.id]
  subnets            = [aws_default_subnet.default_az1.id, aws_default_subnet.default_az2.id]
}

#-----AWS load balancer target group ----

resource "aws_lb_target_group" "web_server_lb_tg" {
  name                 = "WebServer-ALB-TG"
  vpc_id               = aws_default_vpc.default.id
  port                 = "80"
  protocol             = "HTTP"
  deregistration_delay = 10 #seconds
}

#-----AWS load balancer listener-------

resource "aws_lb_listener" "web_server_lb_listener" {
  load_balancer_arn = aws_lb.web_server_lb.arn
  port              = "80"
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.web_server_lb_tg.arn
  }
}

#--------OUTPUTS-----------------

output "web_server_lb_url" {
  value = aws_lb.web_server_lb.dns_name
}

