#/bin/bash

set -x 

yum -y install epel-release

yum install nginx -y

systemctl start nginx 

systemctl enable nginx

firewall-cmd --permanent --add-service=http

systemctl restart firewalld

yum install mariadb-server mariadb -y

systemctl start mariadb

systemctl enable mariadb

mysql_secure_installation

yum install php php-common php-fpm php-mysql -y

sed -i -e 's|cgi.fix_pathinfo=0|cgi.fix_pathinfo=1|' /etc/php.ini 

sed -i -e 's| user = apache | user = nginx |' /etc/php-fpm.d/www.conf
sed -i -e 's| group = apache | group = nginx |' /etc/php-fpm.d/www.conf

systemctl start php-fpm

systemctl enable php-fpm

echo "<?php
phpinfo();
?>" | tee /usr/share/nginx/html/testphp.php

systemctl restart nginx

sed -i -e 's|listen = 127.0.0.1:9000|listen = /var/run/php-fpm/php5-fpm.sock|' /etc/php-fpm.d/www.conf

sed -i -e 's|fastcgi_pass   127.0.0.1:9000;|fastcgi_pass   unix:/var/run/php-fpm/php5-fpm.sock;|' /etc/nginx/nginx.conf

systemctl restart nginx
systemctl restart php-fpm

