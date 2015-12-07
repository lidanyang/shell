#########################################################################
# File Name: test14.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 11时45分59秒
#########################################################################
#!/bin/bash
# testing a multi-position shift

echo "The original parameters : $* "
shift 2
echo "Here is the new first parameters : $1"
