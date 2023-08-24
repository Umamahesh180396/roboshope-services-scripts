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
                echo -e "$1 $R..... Failure $W"
                exit 2
        else
                echo -e "$1 $G..... Success $W"
        fi
}

# Installing redis repo rpm

yum install https://rpms.remirepo.net/enterprise/remi-release-8.rpm -y &>> "$LOG_FILE"

VALIDATE "Installing redis repo rpm"

# Enable Redis 6.2 from package streams

yum module enable redis:remi-6.2 -y &>> "$LOG_FILE"

VALIDATE "Enabling redis 6.2 from package streams"

# Install Redis

yum install redis -y &>> "$LOG_FILE"

VALIDATE "Installing Redis"

# Update listen address from 127.0.0.1 to 0.0.0.0 in /etc/redis.conf & /etc/redis/redis.conf

sed -i 's/127.0.0.1/0.0.0.0/g' /etc/redis.conf /etc/redis/redis.conf

VALIDATE "Modifying redis.conf"

# Start & Enable Redis Service

systemctl enable redis &>> "$LOG_FILE"

VALIDATE "Enabling redis service"

systemctl start redis &>> "$LOG_FILE"

VALIDATE "Starting redis service"

# Validate redis up and running and operational

netstat -tulpn | grep 6379 &>> "$LOG_FILE"

VALIDATE "Redis Up and Operational"