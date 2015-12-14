#! /bin/bash 

name=stephen
test $name != stephen
echo $?

# $?上一条命令执行返回结果
test $name=[Ss]tephen
echo $?

[ $name=stephen ]
echo $?

name=stephen
[[ $name==[Ss]tephen ]]
echo $?

# [[支持通配符
[[ $name==[Ss]tephen &&$friends == "Jose" ]]
echo $?


#shopt打开扩展匹配模式
shopt -s extglob
name=Tommy
[[ $name==[Tt]o+(m)y ]]
echo $?

#((支持的操作符和C语言完全相同
x=2
y=3
((x>2))
echo $?

# test支持的操作符
#
#字符串判断
#[stringA =\==\!= stringB] [string]不为空 [-z string]长度为0 [-n string]不为0
#
#逻辑判断
# [stringA -a stringB] [stringA -o stringB] [!string]
#
#复合判断
# [[pattern1 && \ || pattern2]] [[!pattern]]
#
#整数判断
#
#[ intA -eq\-ne\-gt\-ge\-lt\-le intB]
#
#文件判断中的二进制操作
#
#[ fileA -nt\-ot\-ef fileB ]fileA比fileB新/旧/有相同的设备或者inode值
#
#文件检验
#[ -d -e -f -s -L -r -w -x $file ]
#


