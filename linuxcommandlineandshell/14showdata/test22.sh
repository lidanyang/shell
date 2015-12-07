#########################################################################
# File Name: test22.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 15时37分05秒
#########################################################################
#!/bin/bash
# using the tee command for logging

tempfile=test22file

echo "This is the start of the test"|tee $tempfile
echo "This is the second line of the test"|tee -a $tempfile
echo "This is the end of the test"|tee -a $tempfile
