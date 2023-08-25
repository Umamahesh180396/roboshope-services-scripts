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

# Setup NodeJS repos

curl -sL https://rpm.nodesource.com/setup_lts.x | bash &>> "$LOG_FILE"

VALIDATE "Setting up nodejs repo"

# Install NodeJS

yum install nodejs -y &>> "$LOG_FILE"

VALIDATE "Installing nodejs"

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

curl -L -o /tmp/user.zip https://roboshop-artifacts.s3.amazonaws.com/user.zip &>> "$LOG_FILE"

VALIDATE "Code downloading"

cd /app

unzip /tmp/user.zip

VALIDATE "Unzipping code"

# Install npm dependencies

npm install &>> "$LOG_FILE"

VALIDATE "NPM dependencies installing"

# Setup SystemD user Service

cp -v /home/centos/roboshope-services-scripts/user.service /etc/systemd/system/user.service &>> "$LOG_FILE"

VALIDATE "Creating user service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable user &>> "$LOG_FILE"

VALIDATE "Enabling user service"

systemctl start user &>> "$LOG_FILE"

VALIDATE "Starting user service"

# Creating mongo repo for client installation

cp -v /home/centos/roboshope-services-scripts/mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"

VALIDATE "Repo creation"

# Installing mongodb-client

yum install mongodb-org-shell -y &>> "$LOG_FILE"

VALIDATE "Installing mongodb-shell"

# Load Schema

mongo --host MONGODB-SERVER-IPADDRESS < /app/schema/user.js &>> "$LOG_FILE"

VALIDATE "Schema loading"