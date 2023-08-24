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

# Setup the MongoDB repo file

cp -v /home/centos/roboshope-services-scripts/mongo.repo /etc/yum.repos.d/mongo.repo &>> "$LOG_FILE"

VALIDATE "Settingup mongo.repo"

# Install MongoDB

yum install mongodb-org -y &>> "$LOG_FILE"

VALIDATE "Installing mongodb"

# Start & Enable MongoDB Service

systemctl enable mongod &>> "$LOG_FILE"

VALIDATE "Enabling mongod service"

systemctl start mongod &>> "$LOG_FILE"

VALIDATE "Starting mongod service"

# Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/mongod.conf

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/mongod.conf

VALIDATE "Modifying mongod.conf"

# Restart the service

systemctl restart mongod &>> "$LOG_FILE"

VALIDATE "Restarting mongod service"



