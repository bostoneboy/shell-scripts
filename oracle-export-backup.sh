#!/bin/sh
# Author: Bill JaJa 
# Purpose: Backup the oracle data every day.

DIR_1="/oradata/bakdata"
DIR_2="/export/home/oracle/bakdata"
LOG="/export/home/oracle/bakdata/log/oracle_backup.log"
EXP_LOG="/export/home/oracle/bakdata/log/meg.export.`date +%Y%m%d%H%M%S`.log"
EXP_FILE="meg.export.`date +%Y%m%d%H%M%S`.dmp"
HOLD_DAY=50

# Define function "ECHO", append the timestamp at the head of every echo display.
ECHO () {
printf "%s " `date '+%Y-%m-%d %H:%M:%S'`
echo $1
}

# Run the oracle's environment.
# source /export/home/oracle/.profile
# Verify whether the oracle is running on this host.
PID_SUM=`ps -ef | grep ora_ | grep -v grep | wc -l `
if [ "$PID_SUM" -eq 0 ]
then
        ECHO "oracle is not running on this host."
        exit
else
        ECHO "Oracle datafile backup start."
        /export/home/oracle/product/10/bin/exp $oracle_usrname/$oracle_password FILE="$DIR_1/$EXP_FILE" LOG=$EXP_LOG owner=meg GRANTS=Y INDEXES=Y CONSTRAINTS=Y;
        ECHO "Oracle datafile backup finish."
fi

# Copy the lastest export file to $DIR_2
cp "$DIR_1/$EXP_FILE" $DIR_2/meg.export.dmp
ECHO "Copy the export file [ $EXP_FILE ] to /home/oracle/bakdata/meg.export.dmp..."

# Delete the export dmp file which is old then $HOLD_DAY days.
OLD_FILE=`find $DIR_1 -mtime +$HOLD_DAY -name meg.export.20\*.dmp`
if [ -n "$OLD_FILE" ]
then
        ECHO "File below is older then $HOLD_DAY days and is being deleted."
        echo $OLD_FILE
        find $DIR_1 -mtime +$HOLD_DAY -name meg.export.20\*.dmp -exec rm {} \;
fi

echo "-----------------EOF-----------------"
# End.
