#!/bin/bash
echo "Running setup script..."
sudo apt update -y
sudo apt install -y nginx
echo "Setup complete!" > /home/vagrant/setup_done.txt
