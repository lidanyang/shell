#########################################################################
# File Name: test13.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时49分08秒
#########################################################################
#!/bin/bash
# using an alternative file descriptor

exec 3>test13out

echo "hello"
echo "haha">&3
