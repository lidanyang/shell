#!/bin/bash
#########################################################################
# Author: gnuhpc(http://blog.csdn.net/gnuhpc)
# Created Time: 2015年12月14日 星期一 15时59分46秒
# File Name: punc.sh
# Description: 
#########################################################################

var="'(]\\{}\$\""
echo $var        # '(]\{}$"
echo "$var"      # '(]\{}$"     #同上

echo

IFS='\'
echo $var        # '(] {}$"     \ 字符被空白符替换了, 为什么?
echo "$var"      # '(]\{}$"
echo '$var'      # $var

exit 0
