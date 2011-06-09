#!/bin/bash
# Author: Bill_JaJa
# Modify Date: 2009/11/20

LANG=C;export
log_name="ht-smpp2-`date "+%y%m%d"`.log"
l_log_dir="/dailycheck/log/dailylog/`date +%Y%m`"
r_log_dir="/dailycheck/log/globlelog/`date +%Y%m`"

echo "`date '+%m-%d %H:%M:%S'` start checking system."

if [ ! -d $l_log_dir ] 
then
        mkdir -p $l_log_dir
        if [ $? -eq 0 ]
        then
                echo "`date '+%m-%d %H:%M:%S'` create new dirctory [$l_log_dir] success..."
        else
                echo "`date '+%m-%d %H:%M:%S'` create new dirctory [$l_log_dir] failed..."
                echo "`date '+%m-%d %H:%M:%S'` please check the error..."
        fi
fi

sh /dailycheck/scripts/dailycheck.sh > $l_log_dir/$log_name
echo "`date '+%m-%d %H:%M:%S'` create log file [$log_name] success..."

ftp -n<<!
open $ip_address
user $remote_username $remote_password
cd $r_log_dir
lcd $l_log_dir
prompt
put $log_name
close
bye
!
echo "`date '+%m-%d %H:%M:%S'` push log file [$log_name] to server success..."
echo ">>>>>>>>>>>>>>>>>Finish at `date '+%Y-%m-%d %H:%M:%S'`<<<<<<<<<<<<<<<<<\n"
