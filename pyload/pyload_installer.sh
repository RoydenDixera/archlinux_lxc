#!/bin/bash

# begin of variables
var_service_name="pyload"
var_service_friendly_name="pyLoad"
var_service_friendly_name_length="======"
var_service_default_port="8000"
var_local_ip=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}')
var_local_subnet=$(ip route get 8.8.8.8 | sed -n '/src/{s/.*src *\([^ ]*\).*/\1/p;q}' | sed 's@[^.]*$@0/24@')
# end of variables

clear
echo "====================$var_service_friendly_name_length============="
echo "== Arch Linux LXC - $var_service_friendly_name Installer =="
echo "====================$var_service_friendly_name_length============="
echo
echo "This script will install $var_service_friendly_name."
echo
read -p "Press ENTER to start the script."
echo
echo
echo
echo

echo "Installing $var_service_friendly_name..."
echo "===========$var_service_friendly_name_length==="
read -p "Press ENTER to continue..."
echo
echo "Installing dependencies..."
pacman -Syyu --needed --noconfirm gcc python-pip
echo
echo "Installing $var_service_friendly_name..."
pip install --pre pyload-ng[all]
pip install --upgrade https://github.com/pyload/pyload/archive/refs/heads/develop.zip
echo
echo
echo
echo

echo "Configuring $var_service_friendly_name..."
echo "============$var_service_friendly_name_length==="
read -p "Press ENTER to continue..."
echo
echo "Creating user "pyload"..."
useradd -rU -d /var/lib/pyload/ -s /usr/bin/nologin pyload
echo
echo "Creating pyLoad service..."
cat <<EOF >/usr/lib/systemd/system/pyload.service
[Unit]
Description=pyLoad
After=network.target

[Service]
User=pyload
ExecStart=/usr/bin/pyload --userdir /var/lib/pyload
Restart=on-abort
TimeoutSec=20

[Install]
WantedBy=multi-user.target
EOF
echo
echo "Enabling and starting $var_service_friendly_name to generate config files..."
mkdir -p /var/lib/pyload
chown -R pyload:pyload /var/lib/pyload
systemctl enable --now $var_service_name
echo
echo "Waiting 10 seconds for $var_service_friendly_name to start..."
sleep 10
echo
echo "Stopping $var_service_friendly_name to edit config files..."
systemctl stop $var_service_name
echo
echo "Generating self-signed SSL certificate..."
mkdir -p /var/lib/pyload/ssl
openssl req -x509 -newkey rsa:4096 -sha512 -days 36500 -nodes -subj "/" -keyout /var/lib/pyload/ssl/key.pem -out /var/lib/pyload/ssl/cert.pem
chown -R pyload:pyload /var/lib/pyload/ssl
echo
echo "Enabling HTTPS..."
sed -i 's@ip host : "IP address" =.*@ip host : "IP address" = 0.0.0.0@' /var/lib/pyload/settings/pyload.cfg
sed -i 's@file ssl_certfile : "SSL Certificate" =.*@file ssl_certfile : "SSL Certificate" = /var/lib/pyload/ssl/cert.pem@' /var/lib/pyload/settings/pyload.cfg
sed -i 's@file ssl_keyfile : "SSL Key" =.*@file ssl_keyfile : "SSL Key" = /var/lib/pyload/ssl/key.pem@' /var/lib/pyload/settings/pyload.cfg
sed -i 's@bool use_ssl : "Use HTTPS" =.*@bool use_ssl : "Use HTTPS" = True@' /var/lib/pyload/settings/pyload.cfg
echo
echo
echo
echo

echo "Starting $var_service_friendly_name..."
echo "=========$var_service_friendly_name_length==="
echo "The installation and configuration of $var_service_friendly_name is complete."
echo "Proceed to start $var_service_friendly_name."
echo
read -p "Press ENTER to continue..."
echo
systemctl start $var_service_name
echo "Waiting 5 seconds for $var_service_friendly_name to start..."
sleep 5
echo
echo "You can now access the $var_service_friendly_name web interface."
echo "http://$var_local_ip:$var_service_default_port"
echo
echo "Proceed to display the service status and end the script."
echo
read -p "Press ENTER to continue..."
echo
systemctl status $var_service_name
