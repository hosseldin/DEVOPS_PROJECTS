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

log "==== APP01 TomCat Setup Script Started ===="

log "Updating system packages..."
sudo apt update -y

log "Installing EPEL release..."
sudo apt install epel-release -y

log "Installing java 11"
sudo apt install java-11-openjdk java-11-openjdk-devel -y

log "Installing some dependencies"
sudo apt install git maven wget firewalld -y

log "Checking the version of maven"
mvn -version

log "changing the dir to /tmp"
cd /tmp/

log "Downloads the Tomcat Package"
wget https://archive.apache.org/dist/tomcat/tomcat-9/v9.0.75/bin/apache-tomcat-9.0.75.tar.gz

log "Extracts the Tomcat Package"
tar xzvf apache-tomcat-9.0.75.tar.gz

log "Adds tomcat user"
useradd -m --home-dir /usr/local/tomcat --shell /sbin/nologin tomcat

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

log "Starting and enabling the firewall"
systemctl start firewalld
systemctl enable firewalld

log "allowing port 8080 to access the tomcat"
firewall-cmd --get-active-zones
firewall-cmd --zone=public --add-port=8080/tcp --permanent
firewall-cmd --reload


log "Download the webapp itself"
git clone -b main https://github.com/hkhcoder/vprofile-project.git

log "Build the code inside the repo"
cd vprofile-project
# vim src/main/resources/application.properties
# What should i insert in the properties file?

log "Maven compiles, test, packages and install the Java source code"
mvn install

log "Stops tomcat service momentarily"
systemctl stop tomcat

log "Removing existing ROOT application..."
rm -rf /usr/local/tomcat/webapps/ROOT*

log "Copying new WAR file to Tomcat webapps directory..."
cp target/vprofile-v2.war /usr/local/tomcat/webapps/ROOT.war

log "Starting Tomcat service..."
systemctl start tomcat

log "Changing ownership of Tomcat webapps directory..."
chown tomcat.tomcat /usr/local/tomcat/webapps -R

log "Restarting Tomcat service..."
systemctl restart tomcat


log "==== APP01 Tomcat Setup Script Completed ===="