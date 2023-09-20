#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Security Group
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

resource "aws_security_group" "sg" {
  name        = "${var.env}_SG"
  description = "${var.env}_SG"
  vpc_id      = var.vpc_id

  dynamic "ingress" {
    for_each = var.ports_open
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = [var.vpc_cidr]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1" #Any protocol
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name  = "${var.env}_sg"
    Owner = "Denis Ananev"
  }
}
