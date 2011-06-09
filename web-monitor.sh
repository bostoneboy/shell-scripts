#/bin/sh
# Author:       Bill JaJa
# Purpose:      Monoter the web status, send a alert mail when it's not available.

export LANG=C

URL="$1"
EMAIL="xxxx@yourmail.com"    # change for your mail address.
LOG_FILE="/var/monitor/log/web_status_`date '+%Y%m'`.log"
TMP_EMAIL="/var/monitor/.tmp.mail.`date '+%s'`"

if [ $2 ]
then
        sleep $2
fi

# Define function "ECHO", append the timestamp at the head of every echo display.
ECHO () {
printf "%s " `date '+%Y-%m-%d %H:%M:%S'`
echo $1
}

# Define function HTTP_CODE, obtain the status of web service.
HTTP_CODE () {
http_code=`curl -m 10 -o /dev/null -s -w %{http_code} $URL`
}

# Define function MAIL.
MAIL () {
echo "$URL is not available now, pls pay attention." > $TMP_EMAIL
echo "And the Server 's time is: " >> $TMP_EMAIL
date >> $TMP_EMAIL
echo >> $TMP_EMAIL
echo "------" >> $TMP_EMAIL
echo "BR" >> $TMP_EMAIL
echo "Shell Robot." >> $TMP_EMAIL
mail -s "Server Alert: $URL" $EMAIL < $TMP_EMAIL
rm $TMP_EMAIL
}

n=0
HTTP_CODE
if [ $http_code -eq 200 ]
then
        ECHO "|http_code:200|+$n|webpage visit success.|$URL" >> $LOG_FILE
else
        while [ $http_code -ne 200 ]
        do
                n=`expr $n + 1 `
                ECHO "|http_code:$http_code|+$n|webpage visit failed. |$URL" >> $LOG_FILE
                if [ $n -eq 5 ]; then
                        MAIL $1; exit 0
                fi
                sleep 10
                HTTP_CODE
        done
fi

# End.