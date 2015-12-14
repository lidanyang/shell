#!/bin/bash
#########################################################################
# Author: gnuhpc(http://blog.csdn.net/gnuhpc)
# Created Time: 2015年12月14日 星期一 16时12分46秒
# File Name: 转义.sh
# Description: 
#########################################################################
#!/bin/bash

echo "\v\v\v\v"      # 逐字的打印\v\v\v\v.
# 使用-e选项的'echo'命令来打印转义符.
echo "============="
echo "VERTICAL TABS"
echo -e "\v\v\v\v"   # 打印4个垂直制表符.
echo "=============="

echo "QUOTATION MARK"
echo -e "\042"       # 打印" (引号, 8进制的ASCII 码就是42).
echo "=============="

# 如果使用$'\X'结构,那-e选项就不必要了.
echo; echo "NEWLINE AND BEEP"
echo $'\n'           # 新行.
echo $'\a'           # 警告(蜂鸣).

echo "==============="
echo "QUOTATION MARKS"
# 版本2以后Bash允许使用$'\nnn'结构.
# 注意在这里, '\nnn\'是8进制的值.
echo $'\t \042 \t'   # 被水平制表符括起来的引号(").

# 当然,也可以使用16进制的值,使用$'\xhhh' 结构.
echo $'\t \x22 \t'  # 被水平制表符括起来的引号(").
# 感谢, Greg Keraunen, 指出了这点.
# 早一点的Bash版本允许'\x022'这种形式.
echo "==============="
echo


# 分配ASCII字符到变量中.
# ----------------------------------------
quote=$'\042'        # " 被赋值到变量中.
echo "$quote This is a quoted string, $quote and this lies outside the quotes."

echo

# 变量中的连续的ASCII字符.
triple_underline=$'\137\137\137'  # 137是八进制的'_'.
echo "$triple_underline UNDERLINE $triple_underline"

echo

ABC=$'\101\102\103\010'           # 101, 102, 103是八进制码的A, B, C.
echo $ABC

echo; echo

escape=$'\033'                    # 033 是八进制码的esc.
echo "\"escape\" echoes as $escape"
#                                   没有变量被输出.

echo; echo


#=======================================

 variable=\
 echo "$variable"
 # 不能正常运行 - 会报错:
 # test.sh: : command not found
 # 一个"裸体的"转义符是不能够安全的赋值给变量的.
 #
 #  事实上在这里"\"转义了一个换行符(变成了续航符的含义), 
 #+ 效果就是                variable=echo "$variable"
 #+                      不可用的变量赋值

 variable=\
 23skidoo
 echo "$variable"        #  23skidoo
                         #  这句是可以的, 因为
                         #+ 第2行是一个可用的变量赋值.

 variable=\ 
 #             \^    转义一个空格
 echo "$variable"        # 显示空格

 variable=\\
 echo "$variable"        # \

 variable=\\\
 echo "$variable"
 # 不能正常运行 - 报错:
 # test.sh: \: command not found
 #
 #  第一个转义符把第2个\转义了,但是第3个又变成"裸体的"了,
 #+ 与上边的例子的原因相同.

 variable=\\\\
 echo "$variable"        # \\
                         # 第2和第4个反斜线被转义了.
                         # 这是正确的.

#=======================================

file_list="/bin/cat /bin/gzip /bin/more /usr/bin/less /usr/bin/emacs-20.7"
# 列出的文件都作为命令的参数.

# 加两个文件到参数列表中, 列出所有的文件信息.
ls -l /usr/lib/gconv /usr $file_list

echo "-------------------------------------------------------------------------"

# 如果我们将上边的两个空个转义了会产生什么效果?
ls -l /usr/lib/gconv\ /usr\ $file_list
# 错误: 因为前3个路径被合并成一个参数传递给了'ls -l'
#       而且两个经过转义的空格组织了参数(单词)分割.


mkdir ~/source
mkdir ~/dest
touch ~/source/s.tar

(cd ~/source && tar cf - . ) | \
(cd ~/dest && tar xpvf -)
# 重复Alan Cox的目录数拷贝命令,
# 但是分成两行是为了增加可读性.

# 也可以使用如下方式:
# tar cf - -C ~/source/ . |
# tar xpvf - -C ~/dest/

exit 0
