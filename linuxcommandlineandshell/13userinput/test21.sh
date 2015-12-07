##########################################################################
# File Name: test21.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时02分18秒
#########################################################################
#!/bin/bash
# testing the read command

#-n remove '\n' 
echo -n "Enter your name: "
read name
echo "Hello $name . Welcome to my program."
