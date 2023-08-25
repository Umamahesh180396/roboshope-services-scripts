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

# Install Python 3.6

yum install python36 gcc python3-devel -y &>> "$LOG_FILE"

VALIDATE "Installing Python"

# Add application User if not exist

if [[ ! $(id roboshop) ]]
then
    useradd roboshop
    VALIDATE "User roboshop created"
fi

# This is a usual practice that runs in the organization. Lets setup an app directory if not exist

DIR="/app"
if [[ ! -d "$DIR" ]] 
then
    mkdir "$DIR"
    VALIDATE "$DIR Creation"
fi

# Download the application code to created app directory

curl -L -o /tmp/payment.zip https://roboshop-artifacts.s3.amazonaws.com/payment.zip &>> "$LOG_FILE"

VALIDATE "Downloading code"

cd /app

unzip /tmp/payment.zip

# This python app required dependenies. Lets download

pip3.6 install -r requirements.txt &>> "$LOG_FILE"

VALIDATE "Installing dependencies"

# Setup SystemD Shipping Service

cp -v /home/centos/roboshope-services-scripts/payment.service /etc/systemd/system/payment.service &>> "$LOG_FILE"

VALIDATE "Creating payment service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable payment &>> "$LOG_FILE"

VALIDATE "Enabling payment service"

systemctl start payment &>> "$LOG_FILE"

VALIDATE "Starting payment service"

