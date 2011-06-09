#!/bin/sh
# Purpose:
# Author: Bill JaJa

export LANG=C

DAY=`date "+%e"`
DATE=`date -d yesterday "+%Y-%m-%d"`
CURR_MONTH=`date "+%Y-%m"`
LAST_MONTH=`date -d yesterday "+%Y-%m"`

log_dir="/opt/mcommerce/jboss/server/default/log"
logbak_dir="/var/log/logbak"
logbak_tmp="/var/log/logbak/$CURR_MONTH"

# check the directory, create it if it not exist.
if [ ! -d $logbak_tmp ]
then
        mkdir -p $logbak_tmp
fi

# move yesterday's log file to $logbak_tmp
yesterday_log_file="*$DATE*"
cp $log_dir/$yesterday_log_file $logbak_tmp

# if the day is beginning of a month, zip the last month's log file and then delete the original log file.
# last_month_file="*$LAST_MONTH-??*"
zip_file="jboss.$LAST_MONTH.log.zip"
if [ $DAY -eq 1 ]
then 
        cd $logbak_dir
        if [ $PWD = $logbak_dir ]
        then
                zip $logbak_dir/$zip_file ./$CURR_MONTH/*
                if [ -f $logbak_dir/$zip_file ]
                then
                        rm -rf $logbak_tmp
                fi
        fi
fi

# delete the log which is old than X days.
find $log_dir -name \*log\* -mtime +7 -exec rm {} \;

exit
# The end of the script.
