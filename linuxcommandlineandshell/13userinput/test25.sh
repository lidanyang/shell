#########################################################################
# File Name: test25.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时11分41秒
#########################################################################
#!/bin/bash
# timing the data entry

if read -t 5 -p "Please enter your name:" name
then 
    echo "Hello $name, Welcome to my script"
else
    echo
    echo "Sorry . too Slow!"
fi
