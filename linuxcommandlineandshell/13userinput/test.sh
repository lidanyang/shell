#########################################################################
# File Name: test.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时07分06秒
#########################################################################
#!/bin/bash
#using one command line parameter
factorial=1
for((number = 1;number <= $1;number++))
do
    factorial=$[ $factorial*$number ]
done
echo The factorial of $1 is $factorial
