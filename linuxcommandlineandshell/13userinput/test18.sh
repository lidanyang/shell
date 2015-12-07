#########################################################################
#########################################################################
# File Name: test17.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 13时12分36秒
#########################################################################
#!/bin/bash
# extracting command line options and values

set -- `getopt ab:c "$@"`
while [ -n "$1" ]
do
    case "$1" in 
    -a) echo "Found the -a option";;
    -b) param="$2"
        echo "Found the -b option, with parameter value $param"
        shift;;
    -c) echo "Found the -c option";;
    --) shift 
        break;;
    *) echo "$1 is not an option";;
    esac
    shift
done

count=1
for param in "$@"
do
    echo "Parameter #$count: $param"
    count=$[ $count + 1 ]
done
# File Name: test18.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 13时38分52秒
#########################################################################
#!/bin/bash

