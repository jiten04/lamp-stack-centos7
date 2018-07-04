#!/bin/bash
# setup-lamp-stack-on-cent-os-7.sh
# Let's install our LAMP stack by starting with Apache:
# This script makes use of 'sed' so let's make sure it is installed. While
# we're at it, let's also install 'awk'. It's most likely that these packages
# are already installed, but let's be sure. By the way, yes it is 'gawk' as the 
# pacakge name:warfile

CWD=`pwd`

# Let's make sure that yum-presto is installed:
sudo yum install -y yum-presto

# Let's make sure that mlocate (locate command) is installed as it makes much easier when searching in Linux:
sudo yum install -y mlocate

# Although not needed specifically for running a LAMP stack, I like to use vim, so let's make sure it is installed:
sudo yum install -y vim

# This shell script makes use of wget, so let's make sure it is installed:
sudo yum install -y wget

# it is important to sometimes work with content in a certain format, so let's be sure to install the following:
sudo yum install -y html2text


sudo yum install -y sed
sudo yum install -y gawk

sudo yum install -y httpd mod_ssl openssh
if [ "$isCentOs7" == true ]
then
    sudo systemctl start httpd
else
    sudo service httpd start
fi

# Install MySQL:
if [ "$isCentOs7" == true ]
then
    sudo wget -N http://dev.mysql.com/get/mysql-community-release-el7-5.noarch.rpm
    sudo yum localinstall -y mysql-community-release-el7-5.noarch.rpm
    sudo yum install -y mysql-community-server

    sudo systemctl start mysqld
else
    sudo service mysqld start
fi

# Make sure that we restart MySQL so the changes take effect 
if [ "$isCentOs7" == true ]
then
    sudo systemctl restart mysqld
else
    sudo service mysqld restart
fi

# Open port 3306 for remote connections to MySQL:
if [ "$isCentOs7" == true ]
then
    sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent
    sudo firewall-cmd --reload
else
    sudo iptables -A INPUT -p tcp -m tcp --dport 3306 -j ACCEPT
    sudo service iptables save
    sudo service iptables restart
fi


# added by tones7778:
sudo yum -y install gcc libffi-devel python-devel openssl-devel python-crypto htop nmap python-pip python-setuptools vim-enhanced iftop ifconfig bind-utils moreutils net-tools glances git wget sshpass

sudo -H pip install --upgrade pip
sudo -H pip install paramiko
sudo -H pip install flask fabric ansible



# Install PHP 5.6
sudo yum install -y php56u php56u-mysql php56u-bcmath php56u-cli php56u-common php56u-ctype php56u-devel php56u-embedded php56u-enchant php56u-fpm php56u-gd php56u-hash php56u-intl php56u-json php56u-ldap php56u-mbstring php56u-mysql php56u-odbc php56u-pdo php56u-pear.noarch php56u-pecl-jsonc php56u-pecl-memcache php56u-pgsql php56u-phar php56u-process php56u-pspell php56u-openssl php56u-recode php56u-snmp php56u-soap php56u-xml php56u-xmlrpc php56u-zlib php56u-zip

# Edit the php.ini configuration file and set the default timezone to UTC:
MYPHPINI=`sudo find /etc -name php.ini -print`
PATTERN=';date.timezone =';
REPLACEMENT='date.timezone = EST'
sudo sed -i "s/$PATTERN/$REPLACEMENT/" "$MYPHPINI"
# Also, turn on error logging and outputting errors to browser, which is meant for development environments:
sudo sed -i "s/;error_log = php_errors.log/error_log = php_errors.log/" "$MYPHPINI"
sudo sed -i "s/;display_errors = On/display_errors = On/" "$MYPHPINI"
sudo sed -i "s/;log_errors = On/log_errors = On/" "$MYPHPINI"

# Restart Apache
if [ "$isCentOs7" == true ]
then
    sudo systemctl start httpd
else
    sudo service httpd start
fi

# Add XDebug:
sudo pecl install xdebug
# and be sure to again edit the php.ini file to set the Xdebug extension:
MYPHPINI=`sudo find /etc -name php.ini -print`
XDEBUG=`sudo find /usr -name xdebug.so -print`
INSERT="zend_extension=$XDEBUG"
sudo sed -i "\$a$INSERT" "$MYPHPINI"

# Restart Apache for these php.ini edits to take effect:
if [ "$isCentOs7" == true ]
then
    sudo systemctl start httpd
else
    sudo service httpd start
fi


# Make sure that when the server boots up that both Apache and MySQL start automatically:
if [ "$isCentOs7" == true ]
then
    sudo systemctl enable httpd
    sudo systemctl enable mysqld
else
    sudo chkconfig httpd on
    sudo chkconfig mysqld on
fi

# Let's make sure that git is intalled:
sudo yum install -y git

# Install phpDox, which is needed by Jenkins. If you don't need it, it is ok to comment out the following three sudo commands.
# https://github.com/theseer/phpdox
sudo wget -N http://phpdox.de/releases/phpdox.phar
sudo chmod +x phpdox.phar
sudo mv phpdox.phar /usr/bin/phpdox


# Install 'composer':
sudo curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/bin --filename=composer

# Now that composer is installed, let's install PHPUnit and its associated packages:
sudo composer global require "phpunit/phpunit=4.3.*"
sudo composer global require "phpunit/php-invoker"
sudo composer global require "phpunit/dbunit": ">=1.2"
sudo composer global require "phpunit/phpunit-selenium": ">=1.2"

# PHP CodeSniffer:
sudo composer global require "squizlabs/php_codesniffer"

sudo composer update

sudo wget https://github.com/vrana/adminer/releases/download/v4.3.1/adminer-4.3.1.php
sudo cp adminer-4.3.1.php /var/www/html
sudo mv /var/www/html/adminer-4.3.1.php /var/www/html/adminer.php

echo ""
echo "Finished with setup!"
echo ""
echo "You can verify that PHP is successfully installed with the following command: php -v"
echo "You should see output like the following:"
echo ""
echo "PHP 5.6.4 (cli) (built: Dec 19 2014 10:17:51)"
echo "Copyright (c) 1997-2014 The PHP Group"
echo "Zend Engine v2.6.0, Copyright (c) 1998-2014 Zend Technologies"
echo ""
echo "If you are using CentOS 7, you can restart Apache with this command:"
echo "sudo systemctl restart httpd"
echo ""
echo "The MySQL account currently has no password, so be sure to set one."
echo "You can find info on securing your MySQL installation here: http://dev.mysql.com/doc/refman/5.6/en/postinstallation.html"
echo ""
echo "Happy !"
echo ""
