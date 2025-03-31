#!/bin/bash
echo "Running setup script..."
sudo apt update -y
sudo apt install -y nginx
echo "Setup complete!" > /home/vagrant/setup_done.txt


#!/bin/bash

# Define log file relative to the script
LOG_FILE="/vagrant/logs/app01_log.log"

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

log "==== RMQ01 RabbitMQ Setup Script Started ===="

# Update system and install required packages
log "Updating system packages..."
sudo dnf update -y

log "Installing EPEL release..."
sudo dnf install epel-release -y

log "Installing wget..."
sudo dnf install wget -y
cd /tmp/

log "Installing centos-release-rabbitmq-38..."
sudo dnf install centos-release-rabbitmq-38 -y

log "Enabling CentOS RabbitMQ repository and installing RabbitMQ server..."
sudo dnf --enablerepo=centos-rabbitmq-38 install rabbitmq-server -y

log "Enabling the rabbitMQ service..."
systemctl enable --now rabbitmq-server

log "Configuring RabbitMQ loopback users..."
sudo sh -c 'echo "[{rabbit, [{loopback_users, []}]}]." > /etc/rabbitmq/rabbitmq.config'

log "Adding RabbitMQ user 'test'..."
sudo rabbitmqctl add_user test test

log "Setting 'test' user as an administrator..."
sudo rabbitmqctl set_user_tags test administrator

log "Restarting RabbitMQ service..."
sudo systemctl restart rabbitmq-server


# Starting the firewall and allowing the rabbitmq to access from port no. 5672
log "Starting and enabling the firewall service..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

log "Opening TCP port 11211 in the firewall..."
sudo firewall-cmd --add-port=5672/tcp
sudo firewall-cmd --runtime-to-permanent

log "Starts RabbitMQ service..."
sudo systemctl start rabbitmq-server

log "Enables RabbitMQ service..."
sudo systemctl enable rabbitmq-server

log "Checks the status RabbitMQ service..."
sudo systemctl status rabbitmq-server

log "==== RMQ01 RabbitMQ Setup Script Completed ===="