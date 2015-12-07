#########################################################################
# File Name: test26.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时15分10秒
#########################################################################
#!/bin/bash
# getting just one character of input

read -n1 -p "Do you want to continue?[Y/N]" answer
case $answer in 
    y|Y) echo 
        echo "fine , continue on...";;
    n|N) echo 
        echo OK,goodbye
        exit;;
esac 
echo "This is the end of the script."
