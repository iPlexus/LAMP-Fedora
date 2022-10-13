#!/bin/bash

# Making sure this script runs with elevated privileges
if [ $EUID -ne 0 ]
	then
		echo "Please run this as root!" 
		exit 1
fi

# Updating the system
echo "Updating the system"

dnf check-update
dnf update -y

# Installing Apache, PHP, MariaDB and PHPMyAdmin
echo "Installing required packages"

dnf install httpd httpd-manual php php-pecl-xdebug3 mariadb-server phpMyAdmin -y

# Moving the welcome page
mv /etc/httpd/conf.d/welcome.conf /etc/httpd/conf.d/welcome.conf.mv

# Starting Apache and MariaDB at every boot
echo "Starting services"

systemctl start httpd
systemctl start mariadb
systemctl enable httpd
systemctl enable mariadb

# Installing the MariaDB configuration
echo "Configuring MariaDB"

mysql_secure_installation <<EOF

n
Y
root
root
Y
Y
Y
Y
EOF

# Allowing Apache to writes files
setsebool -P httpd_unified 1

# Creating phpinfo file
echo "<?php phpinfo(); ?>" > /var/www/html/info.php

# Granting permissions to access to the folder
chown -R $USERNAME:$USERNAME /var/www/html/

echo "Your LAMP is ready !"