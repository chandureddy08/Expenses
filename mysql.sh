#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%s)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-TIMESTAMP.log
R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter DB Password:"
read -s mysql_root_password

if [ USERID -ne 0 ]
   then
   echo "Run this script with root access"
else
    echo "You are root user"
fi

VALIDATE(){
    if [ $1 -ne 0 ]
    then
      echo -e "$2...$R FAILURE $N"
      exit 2
    else
      echo -e "$2...$G SUCCESS $N"
    fi
}

dnf install mysql-server -y &>>$LOGFILE
VALIDATE $? "Installing Mysql server"

systemctl enable mysqld &>>$LOGFILE
VALIDATE $? "Enabling Mysql"

systemctl start mysqld &>>$LOGFILE
VALIDATE $? "Starting Mysql"

mysql -h db.chandureddy.online -uroot -p${mysql_root_password} -e 'show databases;' &>>$LOGFILE
if [ $? -ne 0 ]
then
  mysql_secure_installation --set-root-pass ${mysql_root_password} &>>$LOGFILE
  VALIDATE $? "MySQL root password setup"
else
  echo -e "MySQL root passwordis already set up...$Y SKIPPING $N"
fi