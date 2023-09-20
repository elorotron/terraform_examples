#!/bin/bash
yum -y update
yum -y install httpd


myip=`curl http://169.254.169.254/latest/meta-data/local-ipv4`

cat <<EOF > /var/www/html/index.html
<html>
  <head>
    <meta charset="utf-8">
    <title>Terraform web server with Auto Scaling group(launch template)</title>
  </head>
  <body>
    <h2>Web server: $myip</h2>
    <b>New version 4.0</b>
  </body>
</html>
EOF

sudo service httpd start
chkconfig httpd on