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

# Install GoLang

yum install golang -y &>> "$LOG_FILE"

VALIDATE "Installing GoLang"

# Add application User if not exist

id roboshop &>> /dev/null
if [[ $? -ne 0 ]]
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

curl -L -o /tmp/dispatch.zip https://roboshop-artifacts.s3.amazonaws.com/dispatch.zip &>> "$LOG_FILE"

VALIDATE "Code downloading"

cd /app

unzip /tmp/dispatch.zip &>> "$LOG_FILE"

VALIDATE "Unzipping code"

# Lets download the dependencies & build the software

cd /app 
go mod init dispatch
go get
go build

VALIDATE "Dependencies downloading and Building"

# Setup SystemD dispatch Service

cp -v /home/centos/roboshope-services-scripts/dispatch.service /etc/systemd/system/dispatch.service &>> "$LOG_FILE"

VALIDATE "Creating dispatch service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable dispatch &>> "$LOG_FILE"

VALIDATE "Enabling dispatch service"

systemctl start dispatch &>> "$LOG_FILE"

VALIDATE "Starting dispatch service"




