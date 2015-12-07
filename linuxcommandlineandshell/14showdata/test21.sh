#########################################################################
# File Name: test21.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 15时32分32秒
#########################################################################
#!/bin/bash
# using a temporary directory

tempdir=`mktemp -d dir.XXXXXX`
cd $tempdir
tempfile1=`mktemp temp.XXXXXX`
tempfile2=`mktemp temp.XXXXXX`

exec 7>$tempfile1
exec 8>$tempfile2

echo "Sending data to directory $tempdir"
echo "This is a test line of data for $tempfile1">&7
echo "This is a test line of data for $tempfile2">&8
