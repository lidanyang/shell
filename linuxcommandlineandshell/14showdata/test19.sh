#########################################################################
# File Name: test19.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 15时25分40秒
#########################################################################
#!/bin/bash
# creating and using a temp file 

tempfile=`mktemp test19.XXXXX`

exec 3>$tempfile

echo "This script writes to temp file $tempfile"

echo "This is the first line">&3
echo "This is the second line.">&3
echo "This is the last line.">&3
exec 3>&-

echo "Done creating temp file. The contents are:"
cat $tempfile
rm -f $tempfile 2>/dev/null

