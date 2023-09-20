variable "enviroment" {
  default = "DEV"
}

variable "project_name" {
  default = "Sus1"
}

variable "owner" {
  default = "Denis Ananev"
}

variable "allowed_ports" {
  type    = list(any)
  default = ["80", "443"]
}


