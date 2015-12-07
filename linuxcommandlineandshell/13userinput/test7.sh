#########################################################################
# File Name: test7.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时29分22秒
#########################################################################
#!/bin/bash
# testing parameters before use 
if [ -n "$1" ]
then 
    echo Hello $1. glad to meet you
else
    echo "Sorry. you did not identify yourself"
fi
