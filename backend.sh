#!/bin/bash

USERID=$(id -u)
TIMESTAMP=$(date +%F-%H-%M-%S)
SCRIPT_NAME=$(echo $0 | cut -d "." -f1)
LOGFILE=/tmp/$SCRIPT_NAME-TIMESTAMP.log

R="\e[31m"
G="\e[32m"
Y="\e[33m"
N="\e[0m"

echo "Please enter your DB Password:"
read -s mysql_root_password

if [ $USERID -ne 0 ]
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

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? "Disabling Node js"

dnf module enable nodejs:20 -y &>>LOGFILE
VALIDATE $? "Enabling Node js 20"

dnf install nodejs -y &>>LOGFILE
VALIDATE $? "Installing Node js"

id expense
if [ $? -ne 0 ]
then
  useradd expense &>>LOGFILE
  VALIDATE $? "Creating user expense"
else
  echo -e "user expense is already exist...$Y SKIPPING $N"
fi

mkdir -p /app &>>LOGFILE
VALIDATE $? "Creating app Directory"

curl -o /tmp/backend.zip https://expense-builds.s3.us-east-1.amazonaws.com/expense-backend-v2.zip &>>LOGFILE
VALIDATE $? "Downloading backend code"

cd /app &>>LOGFILE
rm -rf /app/*
unzip /tmp/backend.zip &>>LOGFILE
VALIDATE $? "Extracted backend code"

npm install &>>LOGFILE
VALIDATE $? "Installing Node js dependencies"

cp /home/ec2-user/EXPENSES/backend.service /etc/systemd/system/backend.service &>>LOGFILE
VALIDATE $? "Copied backend service"

systemctl daemon-reload &>>$LOGFILE
VALIDATE $? "Daemon Reload"

systemctl start backend &>>$LOGFILE
VALIDATE$? "Starting backend"

systemctl enable backend &>>$LOGFILE
VALIDATE $? "Enabling backend"

dnf install mysql -y &>>$LOGFILE
VALIDATE $? "Installing MySql client"

mysql -h <MYSQL-SERVER-IPADDRESS> -uroot -p${mysql_root_password} < /app/schema/backend.sql &>>$LOGFILE
VALIDATE $? "Schema Loading"

systemctl restart backend &>>$LOGFILE
VALIDATE $? "Restarting the backend"