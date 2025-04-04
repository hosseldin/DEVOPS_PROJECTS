#!/bin/bash

# Define log file relative to the script
LOG_FILE="/vagrant/logs/mon01_log.log"

# Ensure the Logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function for logging messages with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    # echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Redirect all output and errors to the log file as well
exec > >(tee -a "$LOG_FILE") 2>&1

log "==== Sets the correct timezone for the VM ===="
sudo timedatectl set-timezone Africa/Cairo

log "==== MON01 Nagios Monitoring Setup Script Started ===="

# log "Updating system packages..."
# sudo apt update -y

log "Installing EPEL release..."
sudo apt install epel-release -y

log "Installing important needed packages"
sudo apt install wget unzip curl openssl build-essential libgd-dev libssl-dev libapache2-mod-php php-gd php apache2 -y


cd


mkdir -p nagios-core


cd nagios-core


wget -O nagioscore.tar.gz https://github.com/NagiosEnterprises/nagioscore/releases/download/nagios-4.5.9/nagios-4.5.9.tar.gz


tar -xvf nagioscore.tar.gz

ls


cd nagioscore-nagios-4.5.9/


sudo ./configure --with-httpd-conf=/etc/apache2/sites-enabled

sudo make all

sudo make install-group-users

sudo usermod -a -G nagios www-data

log "Installing Nagios Core, Plugins, and NRPE..."
sudo apt install nagios4 nagios-plugins nagios-nrpe-plugin apache2-utils -y


log "Setting up Nagios Admin user..."
sudo htpasswd -cb /etc/nagios4/htpasswd.users nagiosadmin vagrant

log "Restarting Nagios and Apache..."
sudo systemctl restart nagios
sudo systemctl restart apache2



log "Creating an Nginx conf file"
sudo tee /etc/nginx/sites-available/vproapp <<EOF > /dev/null
upstream vproapp {
    server app01:8080;
}
server {
    listen 80;
    location / {
        proxy_pass http://vproapp;
    }
}
EOF

log "Removing default Nginx config"
rm -rf /etc/nginx/sites-enabled/default

log "Creating symlink for vproapp configuration"
ln -s /etc/nginx/sites-available/vproapp /etc/nginx/sites-enabled/vproapp

log "Verify the symlink"
ls -l /etc/nginx/sites-enabled/vproapp

log "Restarting Nginx"
systemctl restart nginx


log "==== MON01 Nagios Monitoring Setup Script Completed ===="
log "=========================================="
log "=========================================="
log "=========================================="
log "=========================================="