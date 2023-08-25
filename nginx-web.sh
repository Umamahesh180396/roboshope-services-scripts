#!/usr/bin/env bash

DATE=$(date +%F)
SCRIPT_NAME="$0"
LOG_FILE=/tmp/$SCRIPT_NAME-$DATE.log

R="\e[31m"
G="\e[32m"
W="\033[0m"

if [[ $(id -u) -ne 0 ]]
then
        echo -e "$R ERROR : Please run this sctipt with root user, swich to root and try $W"
        exit 1
fi

VALIDATE()
{
    if [[ $? -ne 0 ]]
        then
                echo -e "$1 $R ..... Failure $W"
                exit 2
        else
                echo -e "$1 $G ..... Success $W"
        fi
}

# Install Nginx

yum install nginx -y &>> "$LOG_FILE"

VALIDATE "Installing nginx"

# Enable and Start nginx service

systemctl enable nginx &>> "$LOG_FILE"

VALIDATE "Enabling nginx service"

systemctl start nginx &>> "$LOG_FILE"

VALIDATE "Starting nginx service"

# Remove the default content that web server is serving

rm -rf /usr/share/nginx/html/* >> "$LOG_FILE"

VALIDATE "Deleting default content"

# Download the frontend content

curl -o /tmp/frontend.zip https://roboshop-artifacts.s3.amazonaws.com/frontend.zip >> "$LOG_FILE"

VALIDATE "Downloading required content"

# Extract the frontend content

cd /usr/share/nginx/html

unzip /tmp/frontend.zip >> "$LOG_FILE"

# Create Nginx Reverse Proxy Configuration

cp -v /home/centos/roboshope-services-scripts/roboshop.conf /etc/nginx/default.d/roboshop.conf >> "$LOG_FILE"

# Restart Nginx Service to load the changes of the configuration

systemctl restart nginx

VALIDATE "Restarting nginx service"

