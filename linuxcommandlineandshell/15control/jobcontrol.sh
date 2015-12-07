# File Name: jobcontrol.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 17时51分43秒
#########################################################################
#!/bin/bash
# testing job control
# SIGCONT重启一个停止的作业

echo "This is a test program $$"
count=1
while [ $count -le 10 ]
do
    echo "Loop #$count"
    sleep 10
    count=$[ $count + 1 ]
done
echo "This is the end!"
#jobs -l列出PID和作业号
#-n只列出上次shell发出通知后改变了状态的作业
#-p只列出PID
#-r只列出运行中的作业
#-s只列出已经停止的作业
#+表示默认作业
#-表示下一个默认作业
#bg + 作业号 后台模式重启作业
#fg + 作业号 前台模式重启作业

