#########################################################################
# File Name: test19.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 13时44分33秒
#########################################################################
#!/bin/bash
# simple demonstration of the getopts command

while getopts :ab:c opt
do 
    case "$opt" in
    a) echo "Found the -a option";;
    b) echo "Found the -b option,with value $OPTARG";;
    c) echo "Found the -c option";;
    *) echo "Unknow option : $opt";;
    esac
done
