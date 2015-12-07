#########################################################################
# File Name: test14.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时51分41秒
#########################################################################
#!/bin/bash
# retriving the file descriptor

exec 3>&1
exec 1>test14out

echo "This should store in the output"
echo "along with this line"

exec 1>&3

echo "Now things should be back to normal."
