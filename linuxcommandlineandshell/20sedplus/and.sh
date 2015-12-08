#########################################################################
# File Name: and.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 16时51分32秒
#########################################################################
#!/bin/bash

echo "The cat sleeps in his hat. "| sed 's/.at/"&"/g'

echo "1234567"|sed '{:start;s/\(.*[0-9]\)\([0-9]\{3\}\)/\1,\2/;t start}'

echo "The cat sleeps in his hat. "|sed 's/cat/dog/'
