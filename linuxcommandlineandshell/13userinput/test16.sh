#########################################################################
# File Name: test16.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 13时07分02秒
#########################################################################
#!/bin/bash
# extracting options and parameters

while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option";;
    -b) echo "Found the -b option";;
    -c) echo "Found the -c option";;
    --) shift 
        break;;
    *) echo "$1 is not an option";;
    esac
    shift
done

count=1
for param in $@
do
    echo "Parameter #$count:$param"
    count=$[ $count + 1 ]
done

