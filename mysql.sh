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

# CentOS-8 Comes with MySQL 8 Version by default, However our application needs MySQL 5.7. So lets disable MySQL 8 version

yum module disable mysql -y &>> "$LOG_FILE"

VALIDATE "Disabling MySQL 8 Version"

# Setup the MySQL5.7 repo file

cp -v /home/centos/roboshope-services-scripts/mysql.repo /etc/yum.repos.d/mysql.repo &>> "$LOG_FILE"

VALIDATE "Creating mysql.repo"

# Install MySQL Server

yum install mysql-community-server -y &>> "$LOG_FILE"

VALIDATE "Installing mysql-community-server"

# Start and Enable MySQL Service

systemctl enable mysqld &>> "$LOG_FILE"

VALIDATE "Enabling mysql service"

systemctl start mysqld &>> "$LOG_FILE"

VALIDATE "Starting mysql service"

# We need to change the default root password in order to start using the database service. Use password RoboShop@1 or any other as per your choice

mysql_secure_installation --set-root-pass RoboShop@1

VALIDATE "Password setup"

# You can check the new password working or not using the following command in MySQL.

#mysql -uroot -pRoboShop@1

#VALIDATE "MySQL Status Validation"




