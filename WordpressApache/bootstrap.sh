#!/usr/bin/env bash

#Made with help from Digital Ocean Guides
#https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-14-04
#https://www.digitalocean.com/community/tutorials/how-to-install-wordpress-on-ubuntu-14-04

#And my repo
#https://github.com/torch2424/Team-No-Comply-Games-Wordpress

#Remove Non-interactive .bashrc lines
echo "Modifying .bashrc to allow edits"
sed '5,10d;' /home/vagrant/.bashrc > /home/vagrant/.bashrcNew
mv /home/vagrant/.bashrcNew /home/vagrant/.bashrc

#Update The Distro
sudo apt-get update

# Download Lamp stack packages/dev packages
sudo apt-get install -y apache2 php5 libapache2-mod-php5 php5-mcrypt git vim curl

#Download mysql server and phpmyadmin (non-interactive)
#From: https://gist.github.com/rrosiek/8190550
echo "mysql-server mysql-server/root_password password rootpassword" | sudo debconf-set-selections
echo "mysql-server mysql-server/root_password_again password rootpassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/dbconfig-install boolean true" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/app-password-confirm password rootpassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/admin-pass password rootpassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/mysql/app-pass password rootpassword" | sudo debconf-set-selections
echo "phpmyadmin phpmyadmin/reconfigure-webserver multiselect none" | sudo debconf-set-selections
sudo apt-get -y install mysql-server php5-mysql phpmyadmin

# Replace apache dir.conf, enable apache php
sudo cp /vagrant/apache/dir.conf /etc/apache2/mods-enabled/dir.conf

#Restart apache
sudo service apache2 restart

#Set our document root so we can access it
mkdir /vagrant/html
sudo cp /vagrant/apache/000-default.conf /etc/apache2/sites-available/000-default.conf
sudo cp /vagrant/apache/index.php /vagrant/html

#Restart apache
sudo service apache2 restart

#Allow .htaccess overrides
sudo cp /vagrant/apache/apache2.conf /etc/apache2/apache2.conf
sudo a2enmod rewrite
sudo apache2ctl configtest
sudo systemctl restart apache2

#Own the html directory by www-data
sudo chown -R vagrant:www-data /vagrant/html
sudo chmod -R 755 /vagrant/html
#Restart apache for the permissions change
sudo service apache2 restart

#Log into mysql to create a wordpress DB
echo "CREATE DATABASE wordpress;" | mysql -u root -prootpassword
echo "GRANT ALL ON wordpress.* TO 'wordpressuser'@'localhost' IDENTIFIED BY 'password';" | mysql -u root -prootpassword
echo "FLUSH PRIVILEGES;" | mysql -u root -prootpassword


#Clone my bash-it and install
git clone --depth=1 https://github.com/torch2424/bash-it.git ~/.bash_it
~/.bash_it/install.sh < /vagrant/bashItInput.txt
source /home/vagrant/.bashrc

#Cache github credentials for 12 hours
git config --global credential.helper cache
git config --global credential.helper 'cache --timeout=43200'

#Add our awesome ubuntu banner
sudo cp /vagrant/UbuntuBanner/sshd_config /etc/ssh/sshd_config
sudo cp /vagrant/UbuntuBanner/issue.net /etc/issue.net
sudo cp /vagrant/UbuntuBanner/issue.net /etc/motd

#Lastly, remind users to import a wp-config for wordpress
echo "****************************************************"
echo "FINISHED!"
echo "Friendly Reminder: Don't forget to set your keys and"
echo "things for wordpress repos and stuff!"
echo "e.g. wp-config.php, keys.json, etc..."
echo " "
echo "Clone your repos into /vagrant/html"
echo "And go to localhost:8080/repofoldernamehere"
echo "And test by simply going to localhost:8080"
echo "****************************************************"

#Finished!