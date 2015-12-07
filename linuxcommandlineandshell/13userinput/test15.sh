#########################################################################
# File Name: test15.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时48分05秒
#########################################################################
#!/bin/bash
# extracting command line options as parameters

while [ -n "$1" ]
do
    case "$1" in
    -a) echo "Found the -a option";;
    -b) echo "Found the -b option";;
    -c) echo "Found the -c option";;
    *) echo "$1 is not an option";;
    esac
    shift
done
