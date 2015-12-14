#########################################################################
# File Name: Snapshot_Stats.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月11日 星期五 17时45分33秒
#########################################################################
#!/bin/bash 
#创建快照

DATE=`date +%y%m%d`
DISKS_TO_MONITOR="/dev/sda1 /dev/sda2"
MAIL=`which mutt`
MAIL_TO=ldy
REPORT=Snapshot_Stats_$DATE.rpt

exec 3>&1
exec 1>$REPORT

echo -e "\t\tDaily System Report"

echo -e "Today is $DATE"
echo 


# 1) Gather uptime statistics
echo -e "System has been \c"
uptime | sed -n '/,/s/,/ /gp'|
gawk '{if($4 == "days" ||$4 == "day")
{print $2,$3,$4,$5}
else{print $2,$3}}'


# 2) Gather Disk Usage Statistics
echo
for DISK in $DISKS_TO_MONITOR
do 
    echo -e "$DISK usage: \c"
    df -h "$DISK"|sed -n '/% \//p'|gawk '{print $5}'
done

# 3) Gather Memory Usage Statistics
echo
echo -e "Memory Usage: \c"
free |sed -n '2p'|
gawk 'x=int(($3/$2)*100){print x}'|
sed 's/$/%/'

# 4) Gather number of zombie processes
echo
ZOMBIE_CHECK=`ps -al|gawk '{print $2,$4}'|grep Z`
if [ "$ZOMBIE_CHECK" = "" ]
then
    echo "No Zombie process on system at this time"
else
    echo "Current system zombie processes"
    ps -al|gawk '{print $2,$4}'|grep Z
fi 
echo

# Restore output
exec 1>&3 

# Mail
$MAIL -a $REPORT -s "Sytem statistics report for date $DATE" -- $MAIL_TO</dev/null 

# Clean up 
rm -f $REPORT 
