#########################################################################
# File Name: test24.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时08分53秒
#########################################################################
#!/bin/bash
# testing the REPLY environment variable

read -p "Enter a number: "
factorial=1
for((count = 1;count<=$REPLY ;count++))
do
    factorial=$[ $factorial * $count ]
done
echo "The factorial of $REPLY is $factorial"
