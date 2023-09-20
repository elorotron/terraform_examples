#Auto fill parametrs for PROD
#
# File can be named as:
# terraform.tfvars
# *.auto.tfvars
# prod.auto.tfvars
# dev.auto.tfvars
#
# To select tf.vars (if more than one in folder) file type next command:
# terraform apply -var-file="*.auto.tfvars"

region        = "eu-central-1"
instance_type = "t2.micro"

common_tags = {
  Owner     = "Denis Ananev"
  CreatedBy = "Terraform"
  Name      = "variables_lesson"
}

allowed_ports = ["80", "443"]
