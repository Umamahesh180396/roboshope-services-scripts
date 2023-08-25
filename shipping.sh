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

# Maven is a Java Packaging software, Hence we are going to install maven, This indeed takes care of java installation

yum install maven -y &>> "$LOG_FILE"

VALIDATE "Installing maven"

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

curl -L -o /tmp/shipping.zip https://roboshop-artifacts.s3.amazonaws.com/shipping.zip &>> "$LOG_FILE"

VALIDATE "Code downloading"

cd /app

unzip /tmp/shipping.zip &>> "$LOG_FILE"

VALIDATE "Unzipping code"

# Downloading dependenices and building application

mvn clean package &>> "$LOG_FILE"

mv target/shipping-1.0.jar shipping.jar

# Setup SystemD Shipping Service

cp -v /home/centos/roboshope-services-scripts/shipping.service /etc/systemd/system/shipping.service &>> "$LOG_FILE"

VALIDATE "Creating shipping service"

# Load, Enable and Start service

systemctl daemon-reload

systemctl enable shipping &>> "$LOG_FILE"

VALIDATE "Enabling shipping service"

systemctl start shipping &>> "$LOG_FILE"

VALIDATE "Starting shipping service"

# We need to load the schema. To load schema we need to install mysql client

yum install mysql -y &>> "$LOG_FILE"

# Load Schema

mysql -h mysql.robomart.cloud -uroot -pRoboShop@1 < /app/schema/shipping.sql &>> "$LOG_FILE"

VALIDATE "Load schema"

# Restart shipping service to reflect schema changes

systemctl restart shipping &>> "$LOG_FILE"

VALIDATE "Restarting shipping service"


