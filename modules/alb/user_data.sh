# 테스트 후 삭제
#!/bin/bash
sudo yum update -y
sudo yum install -y nginx
echo "${message}" > /usr/share/nginx/html/index.html
sudo systemctl enable nginx
sudo systemctl start nginx
