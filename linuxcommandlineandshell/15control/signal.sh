#########################################################################
# File Name: signal.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 17时35分40秒
#########################################################################
#!/bin/bash
# testing signal trapping 

trap "echo ' Sorry! I have trapped Ctrl-C'" SIGINT SIGTERM
echo This is a test program 
count=8
while [ $count -le 10 ]
do
    echo "Loop #$count"
    sleep 5
    count=$[ $count +1 ]
done
echo This is the end

trap - SIGINT
trap - SIGTERM

trap "echo byebye" EXIT
count=1
while [ $count -le 10 ]
do
    echo "Loop #$count"
    sleep 5
    count=$[ $count +1 ]
done

