#########################################################################
# File Name: priority.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 18时05分50秒
#########################################################################
#!/bin/bash
#nice -n 10 ./test > testout&
#[1] 29432
#nice -n -10 ./test > testout &
#[1] 29543
#$ nice:cannot set priority:Permission denied
#nice组织普通用户增加命令优先级


#./test > test4out &
#ps -al
#renice 10 -p 29560
#限制：只能对属于自己的进程renice
#只能通过renice降低进程优先级
#root可以通过renice任意调整优先级
