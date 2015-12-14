#!/bin/bash
#########################################################################
# Author: gnuhpc(http://blog.csdn.net/gnuhpc)
# Created Time: 2015年12月14日 星期一 16时47分13秒
# File Name: 反转条件.sh
# Description: 
#########################################################################

 true  # "true" 是内建命令.
 echo "exit status of \"true\" = $?"     # 0

 ! true
 echo "exit status of \"! true\" = $?"   # 1
 # 注意: "!" 和指令间需要一个空格
 # 如果一个命令以'!'开头, 那么会启用Bash的历史机制.

 true
 !true
 # 这次就没有错误了, 也没有反转结果.
 # 它只是重复了之前的命令(true)，这种语法在个别版本的bash中并不支持
