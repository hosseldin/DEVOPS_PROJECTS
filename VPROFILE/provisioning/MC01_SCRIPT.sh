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

log "==== DB01 Setup Script Started ===="

log "==== Sets the correct timezone for the VM ===="
sudo timedatectl set-timezone Africa/Cairo

# Update system and install required packages
log "Updating system packages..."
sudo yum update -y

log "Installing EPEL release..."
sudo yum install epel-release -y

# log "Installing packages for shared folders..."
# sudo yum install kernel-devel kernel-headers gcc make perl dkms  -y
# sudo mount /dev/sr0 /mnt
# sudo /mnt/VBoxLinuxAdditions.run

log "Installing Git and MariaDB..."
sudo yum install git mariadb-server -y

# Start and enable MariaDB
log "Starting MariaDB service..."
sudo systemctl start mariadb

log "Enabling MariaDB to start on boot..."
sudo systemctl enable mariadb

# Change the root password
ROOT_PASSWORD="admin123"

log "Setting root password..."
echo "root:$ROOT_PASSWORD" | sudo chpasswd

log "Root password changed successfully."

# Set root password to automate mysql_secure_installation
MYSQL_ROOT_PASSWORD="admin123"

log "Running mysql_secure_installation..."
printf "%s\n" \
  "$ROOT_PASSWORD" \
  "n" \
  "n" \
  "Y" \
  "n" \
  "Y" \
  "Y" | sudo mysql_secure_installation

# Run SQL commands from an external file
log "Running database setup from DB01_SQL.sql..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" < /vagrant/provisioning/DB01_SQL.sql

log "Cloning the VProfile project from GitHub"
git clone -b main https://github.com/hkhcoder/vprofile-project.git

log "Redirecting into the project's directory"
cd vprofile-project


DB_NAME="accounts"
DB_BACKUP="src/main/resources/db_backup.sql"

# Import database backup
log "Importing database backup from $DB_BACKUP..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" < "$DB_BACKUP"

# Connect to MySQL and show tables
log "Verifying tables in $DB_NAME..."
mysql -u root -p"$MYSQL_ROOT_PASSWORD" "$DB_NAME" -e "SHOW TABLES;"

# Restarting MariaDB
log "Restarting MariaDB service..."
sudo systemctl restart mariadb

# Starting the firewall and allowing the mariadb to access from port no. 3306
log "Starting and enabling the firewall service..."
sudo systemctl start firewalld
sudo systemctl enable firewalld

log "Checking active firewall zones..."
sudo firewall-cmd --get-active-zones

log "Opening MySQL port 3306..."
sudo firewall-cmd --zone=public --add-port=3306/tcp --permanent

log "Reloading firewall rules..."
sudo firewall-cmd --reload

# Restarting MariaDB
log "Restarting MariaDB service..."
sudo systemctl restart mariadb


log "==== MYSQL Setup Script Completed ===="