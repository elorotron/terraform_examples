variable "region" {
  description = "Please enter AWS region to delpoy server"
  type        = string
  default     = "eu-central-1"
}

variable "instance_type" {
  description = "Enter instance type"
  type        = string
  default     = "t2.micro"
}

variable "allowed_ports" {
  description = "List of ports to open"
  type        = list(any)
  default     = ["80", "443", "22"]
}

variable "enable_to_find_latest_ami" {
  default = "true"
  type    = bool # enter "true" or "false" other inputs doesn't exist
}

variable "common_tags" {
  description = "Common tag for all resources"
  type        = map(any)
  default = {
    Owner     = "Denis Ananev"
    CreatedBy = "Terraform"
    Name      = "variables_lesson"
  }
}
