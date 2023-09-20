output "webserver_instance_id" {
  value = aws_instance.my_webserver.id
}

output "webserver_public_ip" {
  value = aws_instance.my_webserver.public_ip
}

output "webserver_private_ip" {
  value       = aws_instance.my_webserver.private_ip
  description = "Instance private ip"
}

output "webserver_sg_id" {
  value = aws_security_group.dynamic_sg.id
}

output "webserver_sg_arn" {
  value = aws_security_group.dynamic_sg.arn
}
