#!/bin/bash
export DEBIAN_FRONTEND=noninteractive
set -x

# 패키지 설치
apt-get update -y
apt-get upgrade -y
apt-get install -y apache2 php php-mysql libapache2-mod-php mysql-client unzip curl php-gd php-xml php-curl

# RDS 연결 테스트
mysql -h ${rds_endpoint} -u ${rds_username} -p${rds_password} -e "SHOW DATABASES;" || {
    echo "RDS 연결 실패" >> /tmp/wordpress_deployment.log
    exit 1
}

# DB 생성 및 권한 부여
mysql -h ${rds_endpoint} -u ${rds_username} -p${rds_password} -e "
CREATE DATABASE IF NOT EXISTS ${rds_dbname};
GRANT ALL PRIVILEGES ON ${rds_dbname}.* TO '${rds_username}'@'%';
FLUSH PRIVILEGES;" || {
    echo "DB 생성 및 권한 설정 실패" >> /tmp/wordpress_deployment.log
    exit 1
}

# WordPress 다운로드 및 설치
curl -O https://wordpress.org/latest.tar.gz
tar -xzf latest.tar.gz
cp -r wordpress/* /var/www/html/
rm -f /var/www/html/index.html

# 퍼미션 설정
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# wp-config 설정
cp /var/www/html/wp-config-sample.php /var/www/html/wp-config.php
sed -i "s/database_name_here/${rds_dbname}/g" /var/www/html/wp-config.php
sed -i "s/username_here/${rds_username}/g" /var/www/html/wp-config.php
sed -i "s/password_here/${rds_password}/g" /var/www/html/wp-config.php
sed -i "s/localhost/${rds_endpoint}/g" /var/www/html/wp-config.php

# 디버그 설정 추가
cat <<EOT >> /var/www/html/wp-config.php
define('WP_DEBUG', true);
define('WP_DEBUG_LOG', true);
define('WP_DEBUG_DISPLAY', false);
EOT

# Apache 재시작 및 헬스 체크 파일 생성
systemctl enable apache2
systemctl restart apache2

echo "healthy" > /var/www/html/health
chmod 644 /var/www/html/health

# 설정 로그 저장 (비밀번호 마스킹)
sed 's/${rds_password}/***PASSWORD***/g' /var/www/html/wp-config.php > /tmp/wp-config.php.log
