#########################################################################
# File Name: test11.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时38分42秒
#########################################################################
#!/bin/bash
# testing $* and $@

count=1
for param in "$*"
do 
    echo "\$* Parameter #$count = $param "
    count=$[ $count + 1 ]
done

count=1
for param in "$@"
do
    echo "\$@ Parameter #$count = $param "
    count=$[ $count + 1 ]
done

