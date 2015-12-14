#!/bin/bash
#########################################################################
# Author: gnuhpc(http://blog.csdn.net/gnuhpc)
# Created Time: 2015年12月14日 星期一 16时53分50秒
# File Name: 条件判断.sh
# Description: 
#########################################################################
# 逐字节比较a b两个文件是否相同
if cmp a b &> /dev/null  # 禁止输出.
then echo "Files a and b are identical."
else echo "Files a and b differ."
fi

# 非常有用的"if-grep"结构:
# ------------------------
if grep -q Bash file
then echo "File contains at least one occurrence of Bash."
fi

word=Linux
letter_sequence=inu
if echo "$word" | grep -q "$letter_sequence"
# "-q" 选项是用来禁止输出的.
then
 echo "$letter_sequence found in $word"
else
 echo "$letter_sequence not found in $word"
fi

# 将打里应该理解为子if/then当做一个整体作为测试条件
印Command failed
if COMMAND_WHOSE_EXIT_STATUS_IS_0_UNLESS_ERROR_OCCURRED
then echo "Command succeeded."
else echo "Command failed."
fi 


#=============================#


# 这里应该理解为子if/then当做一个整体作为测试条件
if echo "Next *if* is part of the comparison for the first *if*."
   if [[ $comparison = "integer" ]]
     then (( a < b )) # (( 算数表达式 ))， 用作算数运算
   else
     [[ $a < $b ]]
   fi
then
 echo '$a is less than $b'
fi    
#===================================
 #  小技巧:
 #  如果你不能够确定一个特定的条件该如何进行判断,
 #+ 那么就使用if-test结构.

 echo

 echo "Testing \"0\""
 if [ 0 ]      # zero
 then
   echo "0 is true."
 else
   echo "0 is false."
 fi            # 0 为真.

 echo

 echo "Testing \"1\""
 if [ 1 ]      # one
 then
   echo "1 is true."
 else
   echo "1 is false."
 fi            # 1 为真.

 echo

 echo "Testing \"-1\""
 if [ -1 ]     # 负1
 then
   echo "-1 is true."
 else
   echo "-1 is false."
 fi            # -1 为真.

 echo

 echo "Testing \"NULL\""
 if [ ]        # NULL (空状态)
 then
   echo "NULL is true."
 else
   echo "NULL is false."
 fi            # NULL 为假.

 echo

 echo "Testing \"xyz\""
 if [ xyz ]    # 字符串
 then
   echo "Random string is true."
 else
   echo "Random string is false."
 fi            # 随便的一串字符为真.

 echo

 echo "Testing \"\$xyz\""
 if [ $xyz ]   # 判断$xyz是否为null, 但是...
               # 这只是一个未初始化的变量.
 then
   echo "Uninitialized variable is true."
 else
   echo "Uninitialized variable is false."
 fi            # 未定义的初始化为假.

 echo

 echo "Testing \"-n \$xyz\""
 if [ -n "$xyz" ]            # 更加正规的条件检查.
 then
   echo "Uninitialized variable is true."
 else
   echo "Uninitialized variable is false."
 fi            # 未初始化的变量为假.

 echo


 xyz=          # 初始化了, 但是赋null值.

 echo "Testing \"-n \$xyz\""
 if [ -n "$xyz" ]
 then
   echo "Null variable is true."
 else
   echo "Null variable is false."
 fi            # null变量为假.


 echo


 # 什么时候"false"为真?

 echo "Testing \"false\""
 if [ "false" ]              #  看起来"false"只不过是一个字符串而已.
 then
   echo "\"false\" is true." #+ 并且条件判断的结果为真.
 else
   echo "\"false\" is false."
 fi            # "false" 为真.

 echo

 echo "Testing \"\$false\""  # 再来一个, 未初始化的变量.
 if [ "$false" ]
 then
   echo "\"\$false\" is true."
 else
   echo "\"\$false\" is false."
 fi            # "$false" 为假.
               # 现在, 我们得到了预期的结果.

 #  如果我们测试以下为初始化的变量"$true"会发生什么呢?

 echo
 #========================================
 # (( ... ))结构可以用来计算并测试算术表达式的结果.
# 退出状态将会与[ ... ]结构完全相反!

(( 0 ))
echo "Exit status of \"(( 0 ))\" is $?."         # 1

(( 1 ))
echo "Exit status of \"(( 1 ))\" is $?."         # 0

(( 5 > 4 ))                                      # 真
echo "Exit status of \"(( 5 > 4 ))\" is $?."     # 0

(( 5 > 9 ))                                      # 假
echo "Exit status of \"(( 5 > 9 ))\" is $?."     # 1

(( 5 - 5 ))                                      # 0
echo "Exit status of \"(( 5 - 5 ))\" is $?."     # 1

(( 5 / 4 ))                                      # 除法也可以.
echo "Exit status of \"(( 5 / 4 ))\" is $?."     # 0

(( 1 / 2 ))                                      # 除法的计算结果 < 1.
echo "Exit status of \"(( 1 / 2 ))\" is $?."     # 截取之后的结果为 0.
                                                # 1

(( 1 / 0 )) 2>/dev/null                          # 除数为0, 非法计算.
#           ^^^^^^^^^^^
echo "Exit status of \"(( 1 / 0 ))\" is $?."     # 1

# "2>/dev/null"起了什么作用?
# 如果这句被删除会怎样?
# 尝试删除这句, 然后在运行这个脚本.
#########################################################

a=4
b=5

#  这里的"a"和"b"既可以被认为是整型也可被认为是字符串.
#  这里在算术比较与字符串比较之间是容易让人产生混淆,
#+ 因为Bash变量并不是强类型的.

#  Bash允许对于变量进行整形操作与比较操作.
#+ 但前提是变量中只能包含数字字符.
#  不管怎么样, 还是要小心.

echo

if [ "$a" -ne "$b" ]
then
 echo "$a is not equal to $b"
 echo "(arithmetic comparison)"
fi

echo

if [ "$a" != "$b" ]
then
 echo "$a is not equal to $b."
 echo "(string comparison)"
 #     "4"  != "5"
 # ASCII 52 != ASCII 53
fi

# 在这个特定的例子中, "-ne"和"!="都可以.

echo
#======================================



#  str-test.sh: 检查null字符串和未引用的字符串,
#+ but not strings and sealing wax, not to mention cabbages and kings . . .
#+ 但不是字符串和封蜡, 也并没有提到卷心菜和国王. . . ??? (没看懂, rojy bug)

# 使用   if [ ... ]


# 如果字符串并没有被初始化, 那么它里面的值未定义.
# 这种状态被称为"null" (注意这与零值不同).

if [ -n $string1 ]    # $string1 没有被声明和初始化.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 错误的结果.
# 显示$string1为非null, 虽然这个变量并没有被初始化.


echo


# 让我们再试一下.

if [ -n "$string1" ]  # 这次$string1被引号扩起来了.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi                    # 注意一定要将引用的字符放到中括号结构中!


echo


if [ $string1 ]       # 这次, 就一个$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 这种情况运行的非常好.
# [ ] 测试操作符能够独立检查string是否为null.
# 然而, 使用("$string1")是一种非常好的习惯.
#
# 就像Stephane Chazelas所指出的,
#    if [ $string1 ]    只有一个参数, "]"
#    if [ "$string1" ]  有两个参数, 一个是空的"$string1", 另一个是"]"

echo

string1=initialized

if [ $string1 ]       # 再来, 还是只有$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 再来试一下, 给出了正确的结果.
# 再强调一下, 使用引用的("$string1")还是更好一些, 原因我们上边已经说过了.


string1="a = b"

if [ $string1 ]       # 再来, 还是只有$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
#  str-test.sh: 检查null字符串和未引用的字符串,
#+ but not strings and sealing wax, not to mention cabbages and kings . . .
#+ 但不是字符串和封蜡, 也并没有提到卷心菜和国王. . . ??? (没看懂, rojy bug)

# 使用   if [ ... ]


# 如果字符串并没有被初始化, 那么它里面的值未定义.
# 这种状态被称为"null" (注意这与零值不同).

if [ -n $string1 ]    # $string1 没有被声明和初始化.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 错误的结果.
# 显示$string1为非null, 虽然这个变量并没有被初始化.


echo


# 让我们再试一下.

if [ -n "$string1" ]  # 这次$string1被引号扩起来了.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi                    # 注意一定要将引用的字符放到中括号结构中!


echo


if [ $string1 ]       # 这次, 就一个$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 这种情况运行的非常好.
# [ ] 测试操作符能够独立检查string是否为null.
# 然而, 使用("$string1")是一种非常好的习惯.
#
# 就像Stephane Chazelas所指出的,
#    if [ $string1 ]    只有一个参数, "]"
#    if [ "$string1" ]  有两个参数, 一个是空的"$string1", 另一个是"]"

echo

string1=initialized

if [ $string1 ]       # 再来, 还是只有$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 再来试一下, 给出了正确的结果.
# 再强调一下, 使用引用的("$string1")还是更好一些, 原因我们上边已经说过了.


string1="a = b"

if [ $string1 ]       # 再来, 还是只有$string1, 什么都不加.
then
 echo "String \"string1\" is not null."
else  
 echo "String \"string1\" is null."
fi  
# 未引用的"$string1", 这回给出了错误的结果!

#${file#*/}：删掉第一个 / 及其左边的字符串：dir1/dir2/dir3/my.file.txt
#${file##*/}：删掉最后一个 /  及其左边的字符串：my.file.txt
#${file#*.}：删掉第一个 .  及其左边的字符串：file.txt
#${file##*.}：删掉最后一个 .  及其左边的字符串：txt
#${file%/*}：删掉最后一个  /  及其右边的字符串：/dir1/dir2/dir3
#${file%%/*}：删掉第一个 /  及其右边的字符串：(空值)
#${file%.*}：删掉最后一个  .  及其右边的字符串：/dir1/dir2/dir3/my.file
#${file%%.*}：删掉第一个  .   及其右边的字符串：/dir1/dir2/dir3/my.file.txt

#=====================================================
# zmore

#使用'more'来查看gzip文件

NOARGS=65
NOTFOUND=66
NOTGZIP=67

if [ $# -eq 0 ] # 与if [ -z "$1" ]效果相同
# (译者注: 上边这句注释有问题), $1是可以存在的, 可以为空, 如:  zmore "" arg2 arg3
then
 echo "Usage: `basename $0` filename" >&2
 # 错误消息输出到stderr.
 exit $NOARGS
 # 返回65作为脚本的退出状态的值(错误码).
fi  

filename=$1

if [ ! -f "$filename" ]   # 将$filename引用起来, 这样允许其中包含空白字符.
then
 echo "File $filename not found!" >&2
 # 错误消息输出到stderr.
 exit $NOTFOUND
fi  

if [ ${filename##*.} != "gz" ]
# 在变量替换中使用中括号结构.
then
 echo "File $1 is not a gzipped file!"
 exit $NOTGZIP
fi  

zcat $1 | more

# 使用过滤命令'more.'
# 当然, 如果你愿意, 也可以使用'less'.


exit $?   # 脚本将把管道的退出状态作为返回值.
# 事实上, 也不一定非要加上"exit $?", 因为在任何情况下,
# 脚本都会将最后一条命令的退出状态作为返回值. 
exit 0
