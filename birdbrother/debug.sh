#!/bin/bash
#########################################################################
# Author: gnuhpc(http://blog.csdn.net/gnuhpc)
# Created Time: 2015年12月14日 星期一 15时36分57秒
# File Name: debug.sh
# Description: 
#########################################################################a

EXECUTED_FILE="/home/ldy/myprogram/shell/Update_Problem.sh"
#语法问题
bash -n $EXECUTED_FILE

#运行过程
bash -x $EXECUTED_FILE

#输出脚本代码
bash -v $EXECUTED_FILE
