# 负载代表CPU有多忙 为一说明单个CPU一直在忙

# vmstat 输出 
# r 等待CPU进程数
# b 不可中断休眠进程数
# swpd 使用的虚拟内存总量(MB)
# free 空闲物理内存总量
# buff 用作缓冲的内存总量
# cache 用作高速缓存的内存总量
# si 磁盘交换进来的内存总量
# so 交换到磁盘的内存总量
# in 每秒CPU中断次数
# cs 每秒CPU上下文切换次数
# us 用于执行非内核代码CPU时间百分比
# sy 用于执行内核代码CPU时间百分比
# id 处于空闲状态CPU时间所占百分比
# wa 处于等待I/O的CPU时间所占百分比
##########################
#!/bin/bash 
# Capture_Stats - Gather Sytem Performance Statistics
###########################
#
REPORT_FILE=`pwd`"/capture.csv"
TEMP_FILE=`pwd`"/capstats.html"

DATE=`date +%y/%m/%d.`
TIME=`date +%k:%M:%S`


USERS=`uptime | sed 's/users.*$//' | gawk '{print $NF}'`
LOAD=`uptime | gawk '{print $NF}'`

FREE=`vmstat 1 2| sed -n '/[0-9]/p' | sed -n '2p' | gawk '{print $4}'`
IDLE=`vmstat 1 2| sed -n '/[0-9]/p' | sed -n '2p' | gawk '{print $15}'`

echo "$DATE,$TIME,$USERS,$LOAD,$FREE,$IDLE">>$REPORT_FILE

