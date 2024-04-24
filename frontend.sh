#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

if [ USERID -ne 0 ]
then
  echo "please run this script with root access"
  exit 5
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

dnf install nginx -y &>>$LOGFILE
VALIDATE $? "Installing ngnix"

systemctl enable nginx &>>$LOGFILE
VALIDATE $? "Enabling nginx"

systemctl start nginx &>>$LOGFILE
VALIDATE $? "Starting Nginx"

rm -rf /usr/share/nginx/html/* &>>$LOGFILE
VALIDATE $? "Removing the existing content"

curl -o /tmp/frontend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-frontend-v2.zip &>>$LOGFILE
VALIDATE $? "Downloading the frontend code"

cd /usr/share/nginx/html &>>$LOGFILE
unzip /tmp/frontend.zip &>>$LOGFILE
VALIDATE $? "Extracting frontend code"

cp /home/ec2-user/EXPENSES/expense.conf /etc/nginx/default.d/expense.conf &>>$LOGFILE
VALIDATE $? "Copying expense configuration"

systemctl restart nginx &>>$LOGFILE
VALIDATE $? "Restarting Nginx"

