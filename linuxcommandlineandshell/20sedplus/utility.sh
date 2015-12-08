#########################################################################
# File Name: utility.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 17时18分43秒
#########################################################################
#!/bin/bash
#加倍行间距
sed 'G' data2

#除了最后一行加倍行间距
sed '$!G' data2

#对有空白行的加倍行间距
sed '{/^$/d;$!G}' data6

#对行编号
sed '=' data2| sed '{N ; s/\n/ /}'

#打印末尾行
sed '{
:start 
$q
N
11,$D
b start
}' /etc/passwd 

#删除连续空白行
sed '/./,/^$/!d' data6

#删除开头空白行
sed '/./,$!d' data6

#删除结尾空白行
sed '{
:start
/^\n*$/{$d; N; b start }
}' data6

#删除html标签
sed 's/<[^>]*>//g' $1 
