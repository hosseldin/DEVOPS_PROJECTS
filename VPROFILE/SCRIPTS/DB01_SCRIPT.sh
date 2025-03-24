#!/bin/bash

echo "Running setup script for the MYSQL Setup..."

# Update system and install required packages
sudo yum update -y
sudo yum install epel-release -y
sudo yum install git mariadb-server -y

# Start and enable MariaDB
sudo systemctl start mariadb
sudo systemctl enable mariadb

# Set root password and automate mysql_secure_installation
MYSQL_ROOT_PASSWORD="admin123"

printf "%s\n" \
  "Y" \
  "$MYSQL_ROOT_PASSWORD" \
  "$MYSQL_ROOT_PASSWORD" \
  "Y" \
  "n" \
  "$MYSQL_ROOT_PASSWORD" \
  "Y" \
  "Y" \
  "Y" \
  "Y" | sudo mysql_secure_installation


echo "Setup complete!" > /home/vagrant/setup_done.txt

# Will this work