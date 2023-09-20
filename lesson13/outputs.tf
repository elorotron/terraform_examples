output "server_ip" {
  value = data.aws_ami.latest_linux.public
}

output "server_id" {
  value = data.aws_ami.latest_linux.id
}

output "security_group_id" {
  value = aws_security_group.dynamic_sg.id
}
