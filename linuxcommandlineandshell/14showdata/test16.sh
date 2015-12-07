#########################################################################
# File Name: test16.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 15时03分55秒
#########################################################################
#!/bin/bash
# testing input/output file descriptor

exec 3<>testfile
read line <&3
echo "Read: $line"
echo "This is a test line">&3

exec 3>&-

exec 3>test17file
echo "This is a test line of data">&3
exec 3>&-

cat test17file

exec 3>test17file
echo "This'll be bad">&3
