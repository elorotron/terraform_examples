variable "ports_open" {
  default = [
    "80",
    "443",
    "22"
  ]
}

variable "vpc_id" {
  description = "VPC id from vpc-prod module "
}

variable "env" {
  description = "Value for env variable from vpc-prod module"
}

variable "vpc_cidr" {
  description = "cidr block from vpc-prod module"
}
