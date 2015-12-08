#########################################################################
# File Name: directorycount.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 14时46分22秒
#########################################################################
#!/bin/bash 

echo "目录计数"
mypath=`echo $PATH | sed 's/:/ /g'`

count=0
for directory in $mypath
do
    check=`ls $directory`
    for item in $check
    do
        count=$[ $count + 1 ]
    done
    echo "$directory-$count"
    count=0
done
