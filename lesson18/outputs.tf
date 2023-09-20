//Print all details of users
output "created_iam_users_all" {
  value = aws_iam_user.iam_users
}

//Print onli ID of all users
output "created_iam_users_ids" {
  value = aws_iam_user.iam_users[*].id
}

//Print NAME  with ARN list
output "created_iam_users_custom" {
  value = [
    for boba in aws_iam_user.iam_users :
    "Username: ${boba.name} has ARN: ${boba.arn}"
  ]
}

//Print unique_id with id MAP
output "created_iam_users_map" {
  value = {
    for user in aws_iam_user.iam_users :
    user.unique_id => user.id #unique_id : user.id (=> - =)
  }
}

//Print name users if lenght <= 5 only
output "custom_if_lenght" {
  value = [
    for x in aws_iam_user.iam_users :
    x.name
    if length(x.name) <= 5
  ]
}

#--------------------------------EC2 Instance

//Print server id and public ip of all servers
output "server_all" {
  value = {
    for server in aws_instance.servers :
    server.id => server.public_ip
  }
}
