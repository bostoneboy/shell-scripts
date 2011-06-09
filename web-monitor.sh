#/bin/sh
# Author:       Bill JaJa
# Purpose:      Monoter the web status, send a alert mail when it's not available.

#此shell脚本用于监控网站运行情况，原理是按固定频率不停访问给出的URL，当网站不可访问时自动给设定邮箱发送告警邮件以通知用户。
#可配置字段，脚本第二段中有如下三个可配置字段：
#  EMAIL：接收告警信息的email地址。
#  LOG_FILE：日志文件，建议使用绝对路径；最后的web_status_`date ‘+%Y%m’`.log代表以月为单位分割日志，如web_status_201105.log
#  TMP_EMAIL：临时邮件文件，同样建议使用绝对路径，保持所在目录有写权限即可。
#使用方法：
#  脚本后面需跟两个参数：第一个参数为监控网站的URL，第二个参数为延时时间（可选，以秒为单位，建议在对多个网站进行监控时添加），
#  将此脚本添加到操作系统的crontab里面，按需求设定运行频率，建议2分钟一次。若有多个网站需监控，在crontab里面添加多行即可，
#  每个URL一行，如下为同时对三个网站进行监控：
#  */2 * * * * sh /var/monitor/web_monitor.sh http://www.qq.com
#  */2 * * * * sh /var/monitor/web_monitor.sh http://www.qqq.com 5
#  */2 * * * * sh /var/monitor/web_monitor.sh http://www.qqqq.com 10

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