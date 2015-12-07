#########################################################################
# File Name: at.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 18时11分00秒
#########################################################################
#!/bin/bash
#每60检查一次 /var/spool/at atd守护进程
#at [-f filename] time
#时间格式:10:15 10:15~PM now noon midnight teatime(4~PM)
#日期格式:MMDDYY MM/DD/YY DD.MM.YY  July 4 Dec 25
#当前时间+25min 明天10:15~PM 10:15+7天
#提交到作业队列中 a~z种不同优先级 字母排序
#愈高，优先级愈低 -q指定不同的队列字母

# testing the at command

echo "This script ran at `date`"
echo "This is end!">&2

#atq查看作业队列中等待中的作业
#atrm删除等待中的作业

#计划定期执行脚本
#cron时间表
#min hour dayofmonth month dayofweek command
#usage:15 10 * * * command
#dayofweek: mon tue wed thu fri sat sun
#00 12 * * * if[`date+%d -d tomorrow`=01];then;command

#cron时间表
#crontab -l 
#-e添加条目
#cron目录不要求jingque的执行时间 hourly daily monthly weekly

#anacron用于运行错过时间的脚本 用于常规日志的维护
#sudo cat /var/spool/anacron/cron.monthly 
#cat /etc/anacrontab自己用来检查作业目录的表
#格式period delay identifier command identifier非空白字符串 用于唯一识别日志消息和错误E-mail中的作业 delay启动多少分钟后运行错过的脚本
#anacron不会运行/etc/cron.hourly的脚本
#

