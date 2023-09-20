#-----------------------------------------------------------------------------------------------------------------
# My Terraform
#
# Generate passwords, saving in SSM Parameter store
#
# Made by Denis Ananev
#-----------------------------------------------------------------------------------------------------------------

provider "aws" {
  region = "eu-central-1"
}

#------Create random pasword--------------

resource "random_string" "rds_psw" {
  length           = 12
  special          = true #include special symbols in psw
  override_special = "!#$%_"
  keepers = {
    keeper1 = var.name #if variable changed, chenge password
  }
}

variable "name" {
  default = "denis"
}

#--------Create password in AWS Parametr store---------

resource "aws_ssm_parameter" "rds_psw" {
  name        = "/prod/mysql"
  description = "Master Password for RDS MySQL"
  type        = "SecureString"
  value       = random_string.rds_psw.result
}

#-------------------------------------

data "aws_ssm_parameter" "my_rds_pswd" {
  name       = aws_ssm_parameter.rds_psw.name
  depends_on = [aws_ssm_parameter.rds_psw]

}

output "rds_password" {
  value = nonsensitive(data.aws_ssm_parameter.my_rds_pswd.value) #NOT SECURE
}

#-----------AWS DB Instance-----------------------------

resource "aws_db_instance" "default" {
  identifier           = "prod-rds"
  allocated_storage    = 10
  db_name              = "mydb_prod"
  engine               = "mysql"
  engine_version       = "5.7"
  instance_class       = "db.t3.micro"
  username             = "administrator"
  password             = data.aws_ssm_parameter.my_rds_pswd.value
  parameter_group_name = "default.mysql5.7"
  skip_final_snapshot  = true
  apply_immediately    = true
}
