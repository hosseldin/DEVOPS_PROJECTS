#!/bin/bash

# Define log file relative to the script
LOG_FILE="/vagrant/logs/mc01_log.log"

# Ensure the Logs directory exists
mkdir -p "$(dirname "$LOG_FILE")"

# Function for logging messages with timestamp
log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1"
    # echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" | tee -a "$LOG_FILE"
}

# Redirect all output and errors to the log file as well
exec > >(tee -a "$LOG_FILE") 2>&1

log "==== MC01 Memcached Setup Script Started ===="

log "==== Sets the correct timezone for the VM ===="
sudo timedatectl set-timezone Africa/Cairo

# Update system and install required packages
log "Updating system packages..."
# sudo dnf update -y

log "Installing EPEL release..."
sudo dnf install epel-release -y

log "Installing MemCached..."
sudo dnf install memcached -y

# Start and enable MemCached
log "Starting memcached service..."
sudo systemctl start memcached

log "Enabling memcached to start on boot..."
sudo systemctl enable memcached

log "Checks the status of memcached..."
sudo systemctl enable memcached

log "Allows other machines to connect to MemCached..."
sed -i 's/127.0.0.1/0.0.0.0/g' /etc/sysconfig/memcached

log "Restarting memcached service..."
sudo systemctl restart memcached

# Starting the firewall and allowing the mariadb to access from port no. 3306
log "Starting and enabling the firewall service..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

log "Opening TCP port 11211 in the firewall..."
sudo firewall-cmd --add-port=11211/tcp
sudo firewall-cmd --runtime-to-permanent

log "Opening UDP port 11111 in the firewall..."
sudo firewall-cmd --add-port=11111/udp
sudo firewall-cmd --runtime-to-permanent

log "Starting Memcached on port 11211 (TCP) and 11111 (UDP)..."
sudo memcached -p 11211 -U 11111 -u memcached -d

log "==== MC01 MemCached Setup Script Completed ===="
log "=========================================="
log "=========================================="
log "=========================================="
log "=========================================="