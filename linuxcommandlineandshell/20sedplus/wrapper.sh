#########################################################################
# File Name: wrapper.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 16时57分29秒
#########################################################################
#!/bin/bash
#sed -n '{1!G; h ;$p}' $1

factrial=1
counter=1
number=$1

function f {
    if [ $1 -eq 1 ]
    then
        echo $1
    else
        result=`f $[ $1 - 1 ]`
        echo $[ $1*$result ]
    fi 
}

factrial=`f $number`
result=`echo $factrial|sed '{:start;s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;t start}'`
echo "The result is $result"
