#########################################################################
# File Name: test15.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时55分52秒
#########################################################################
#!/bin/bash
# redirecting and retriving input descriptor

exec 6<&0
exec 0<testfile

count=1
while read line
do
    echo "Line #$count: $line"
    count=$[ $count + 1 ]
done
exec 0<&6
read -p "Are you done now?" answer
case answer input
Y|y) echo "Goodbye";;
N|n) echo "Sorry. This is the end.";;
esac

