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

log "Open a root interactive shell..."
sudo -i

log "Updating system packages..."
sudo apt update -y

log "Installing EPEL release..."
sudo apt install epel-release -y

log "Installing Nginx"
sudo apt install nginx -y

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