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

dnf module disable nodejs -y &>>LOGFILE
VALIDATE $? ""Disabling Node js"