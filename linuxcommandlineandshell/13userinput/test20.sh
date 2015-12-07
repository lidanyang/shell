#########################################################################
# File Name: test20.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 13时50分32秒
#########################################################################
#!/bin/bash
# processing options and parameters with getopts

echo "$@"
while getopts :ab:cd opt
do
    case "$opt" in
        a) echo "Found the -a option";;
        b) echo "Found the -b option,with value $OPTARG";;
        c) echo "Found the -c option";;
        d) echo "Found the -d option";;
        *) echo "Unknow option :$opt";;
    esac
done

echo  $OPTIND
shift $[ $OPTIND - 1 ]

count=1
for param in "$@"
do 
    echo "Parameter $count: $param"
    count=$[ $count + 1 ]
done
