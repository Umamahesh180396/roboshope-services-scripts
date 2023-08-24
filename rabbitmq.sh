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

# Configure YUM Repos from the script provided by vendor

curl -s https://packagecloud.io/install/repositories/rabbitmq/erlang/script.rpm.sh | bash &>> "$LOG_FILE"

VALIDATE "Configuring erlnag yum repos"

# Configure YUM Repos for RabbitMQ.

curl -s https://packagecloud.io/install/repositories/rabbitmq/rabbitmq-server/script.rpm.sh | bash &>> "$LOG_FILE"

VALIDATE "Configuring Rabbit MQ YUM Repos"

# Install RabbitMQ

yum install rabbitmq-server -y &>> "$LOG_FILE"

VALIDATE "Installing rabbitmq-server"

# Enable and Start RabbitMQ Service

systemctl enable rabbitmq-server &>> "$LOG_FILE"

VALIDATE "Enabling RabbitMQ Service"

systemctl start rabbitmq-server &>> "$LOG_FILE"

VALIDATE "Starting RabbitMQ Service"

#RabbitMQ comes with a default username / password as guest/guest. But this user cannot be used to connect. Hence, we need to create one user for the application

rabbitmqctl add_user roboshop roboshop123 &>> "$LOG_FILE"

VALIDATE "Adding user roboshop"

rabbitmqctl set_permissions -p / roboshop ".*" ".*" ".*" &>> "$LOG_FILE"

VALIDATE "Setting up permissions"


