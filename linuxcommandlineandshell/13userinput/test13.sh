#########################################################################
# File Name: test13.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时44分06秒
#########################################################################
#!/bin/bash
# demonstrating the shift command 

count=1
while [ -n "$1" ]
do
    echo "Parameter #$count = $1"
    count=$[ $count +1 ]
    shift
done
