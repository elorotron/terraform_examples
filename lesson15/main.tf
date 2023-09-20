#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# exec-local
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

resource "null_resource" "command1" {
  provisioner "local-exec" {
    command = "echo Terraform START: $(date) >> log.txt"
  }
}

resource "null_resource" "command2" {
  provisioner "local-exec" {
    command = "ping -c 5 www.google.com"
  }
}

resource "null_resource" "command3" {
  provisioner "local-exec" {
    command     = "print('Hello world!')"
    interpreter = ["python3", "-c"]
  }
}

resource "null_resource" "command4" {
  provisioner "local-exec" {
    command = "echo $NAME1 $NAME2 $NAME3 >> names.txt"
    environment = {
      NAME1 = "Denis"
      NAME2 = "Vlad"
      NAME3 = "Vasilevs"
    }
  }
}

resource "aws_instance" "server" {
  ami           = "ami-06fd5f7cfe0604468"
  instance_type = "t2.micro"
  provisioner "local-exec" {
    command = "echo Hellow world AWS Instance"
  }
}

resource "null_resource" "command5" {
  provisioner "local-exec" {
    command = "echo Terraform END: $(date) >> log.txt"
  }
  depends_on = [null_resource.command1, null_resource.command2, null_resource.command3, null_resource.command4, aws_instance.server]
}
