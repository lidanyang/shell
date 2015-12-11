#########################################################################
# File Name: disk.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月11日 星期五 15时03分50秒
#########################################################################
#!/bin/bash 
# Big_Users - find big disk space users in various directories
#########################################################################
# Parameters for Script 
#
CHECK_DIRECTORIES="/var/log /home" #directories to check 
#
#########################################################################
#
DATE=$(date '+%m%d%y') #Date for report file 
#
exec > disk_space_$DATE.rpt
#
echo "Top Ten Disk Space Usage"
echo "for $CHECK_DIRECTORIES directories"

for DIR_CHECK in $CHECK_DIRECTORIES
do
    echo ""
    echo "The $DIR Directory:"
#
# Create a listing of top ten disk space users

    sudo du -S $DIR_CHECK 2>/dev/null |
    sort -rn|
    sed '{11,$D;=}'|
    sed '{N;s/\n/ /}'|
    gawk '{print $1 ":" "\t" $2 "\t" $3}'
done
