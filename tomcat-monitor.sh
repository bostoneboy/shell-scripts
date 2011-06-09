#!/bin/sh
# Purpose: monitor the tomcat process, restart it when the webpage is down.
# install this script in the root's crontab.
# Author : Bill JaJa
# Modify Time: 2011/01/14

URL="http://localhost/xxx/xxx.html"   # change for your url/uri.
# EMAIL="xxxx@yourmail.com"
LOG_FILE="/var/logs/monitor_tomcat.log"    # change it if you want.

# run the profile of globle and user mcc first.
. /etc/profile
LANG=C; export LANG

# the key value used for grep process of tomcat.
KEY="tomcat5/conf/logging.properties"

# Define function "ECHO", append the timestamp at the head of every echo display.
ECHO () {
printf "%s " `date '+%Y-%m-%d %H:%M:%S'`
echo $1
}

# Define function HTTP_CODE, obtain the status of web service.
HTTP_CODE () {
http_code=`curl -m 10 -o /dev/null -s -w %{http_code} $URL`
}

count=0
HTTP_CODE
while [ $http_code -ne 200 -a $count -lt 3 ]
do
  sleep 5
  HTTP_CODE
  count=`expr $count + 1`
  if [ $count -eq 3 ]
  then
    ECHO "http_code: $http_code"  >> $LOG_FILE
    # kill the process of tomcat.
    TOMCAT_STATUS=100
    while [ $TOMCAT_STATUS -ne 0 ]
    do
      ECHO "tomcat process is shutdowning..." >> $LOG_FILE
      PID=`ps -ef | grep "$KEY" | grep -v grep | awk '{print $2}'`
      if [ -z "$PID" ]
      then
        break
      else
        for i in $PID
        do
          kill -9 $i
        done
      fi
      TOMCAT_STATUS=`ps -ef | grep "$KEY" | grep -v grep | wc -l`
    done
    ECHO "tomcat process is shutdowned." >> $LOG_FILE
    sleep 20
    
    # restart the tomcat.
    TOMCAT_STATUS=0
    BIN_DIR="/opt/colornotes/tomcat5/bin"
    while [ $TOMCAT_STATUS -eq 0 ]
    do
      ECHO "tomcat process is restarting..."  >> $LOG_FILE
      cd $BIN_DIR
      ./startup.sh &
      sleep 5
      TOMCAT_STATUS=`ps -ef | grep "$KEY" | grep -v grep | wc -l`
    done
    ECHO "tomcat process started." >> $LOG_FILE
  fi
done
exit 0
