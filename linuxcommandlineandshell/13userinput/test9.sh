#########################################################################
# File Name: test9.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时32分41秒
#########################################################################
#!/bin/bash
# testing parameters

if [ $# -ne 2 ]
then 
    echo Usage: test9 a b
else
    total=$[ $1 + $2]
    echo The total is $total
fi
