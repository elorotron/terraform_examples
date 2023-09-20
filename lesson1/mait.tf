provider "aws" {
  region = "eu-central-1" #us-east-1
}


resource "aws_instance" "my_aws_linux" {
  count         = 2
  ami           = "ami-08a52ddb321b32a8c"
  instance_type = "t2.micro"
}
