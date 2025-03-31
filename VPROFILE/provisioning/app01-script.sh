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

log "Installing java 11"
sudo dnf install java-11-openjdk java-11-openjdk-devel -y

log "Installing some dependencies"
sudo dnf install git maven wget -y

log "changing the dir to /tmp"
cd /tmp/

log "Downloads the Tomcat Package"
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz

log "Extracts the Tomcat Package"
tar xzvf apache-tomcat-9.0.75.tar.gz

log "Adds tomcat user"
useradd --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

log "Copies data to tomcat home dir"
cp -r /tmp/apache-tomcat-9.0.75/* /usr/local/tomcat/

log "Make tomcat user owner of tomcat home dir"
chown -R tomcat.tomcat /usr/local/tomcat

log "Creating a tomcat service..."
log "Create a tomcat service file..."
sudo tee /etc/systemd/system/tomcat.service <<EOF > /dev/null
[Unit]
Description=Tomcat
After=network.target

[Service]
User=tomcat
WorkingDirectory=/usr/local/tomcat
Environment=JRE_HOME=/usr/lib/jvm/jre
Environment=JAVA_HOME=/usr/lib/jvm/jre
Environment=CATALINA_HOME=/usr/local/tomcat
Environment=CATALINE_BASE=/usr/local/tomcat
ExecStart=/usr/local/tomcat/bin/catalina.sh run
ExecStop=/usr/local/tomcat/bin/shutdown.sh
SyslogIdentifier=tomcat-%i

[Install]
WantedBy=multi-user.target
EOF

log "Reload the systemd files"
systemctl daemon-reload

log "Enable the tomcat service..."
systemctl start tomcat
systemctl enable tomcat

Enabling the firewall and allowing port 8080 to access the tomcat
systemctl start firewalld
systemctl enable firewalld
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload







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