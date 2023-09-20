output "webserver_sg_id" {
  value = aws_security_group.dynamic_sg.id
}

output "webserver_public_ip" {
  value = aws_instance.webserver.public_ip
}
