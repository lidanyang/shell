#########################################################################
# File Name: gawk.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月09日 星期三 09时15分04秒
#########################################################################
#!/bin/sh
#=========
#gawk数据字段
#FILEDWIDTHS 由空格分开的定义了每个数据字段宽度的一列数字
#FS 输入字段分隔符
#RS 输入数据行分隔符
#OFS 输出字段分隔符
#ORS 输出数据行分隔符


gawk 'BEGIN{FILEWIDTHS="3 5 2 5"}{print $1,$2,$3,$4}' data1

#数据变量
#ARGC 参数个数
#ARGIND 当前文件在ARGV中的位置
#ARGV 参数数组
#CONVFMT 转换格式 默认%.6 g
#ENVIRON 环境变量关联数组
#ERRNO 读取或者关闭输入文件错误发生时的系统错误号
#FILENAME 输入数据的数据文件名
#FNR 数据行数
#IGNORECASE 非零值 忽略字符串大小写
#NF 字段总数
#NR 已处理的行数
#OFMT 数字输出格式 默认"%.6 g"
#RLENGTH match函数所匹配的字符串长度
#RSTART match函数匹配的字符串起始位置

gawk 'BEGIN{print ARGC,ARGV[1]}' data1

gawk 'BEGIN{FS=":";OFS=":"} {print $1,$NF}' /etc/passwd 

gawk 'BEGIN{FS=","}{print $1,"FNR="FNR}' data1 data1

gawk 'BEGIN{FS=","}{print $1,"FNR="FNR,"NR="NR}END{print "There\
    were ",NR,"records processed"}' data1 data1

#脚本中给变量赋值
gawk 'BEGIN{x=4;x = x * 2 + 3;print x}'

#命令行上给脚本赋值
gawk -f script1 n=3 data1
#n在BEGIN部分不可以用

gawk -v n=3 -f script2 data1
#命令行上设的值在BEGIN可用

#var[index]=element
gawk 'BEGIN{
capital["Illinois"]="Springfield"
print capital["Illinois"]
}'

#for (var in array) { statements }
#不按顺序
gawk 'BEGIN{
var["a"]=1
var["g"]=2
for(test in var)
{
    print "Index:",test,"- Value:",var[test]
}
delete var["g"]
print "---"
for(test in var)
{
    print "Index:",test,"- Value:",var[test]   
}
}'

#使用正则表达式
gawk 'BEGIN{FS=","} /.d/{print $1}' data1

#匹配操作符
gawk 'BEGIN{FS=","} $2~/^data2/{print $0}' data1
gawk 'BEGIN{FS=","} $2 !~ /^data2/{print $0}' data1

#数学表达式
gawk -F, '$1=="data11"{print $0}' data1

#结构化命令
#if(condition) statement1
#if(condition) statement1; else statement2
#while(condition) {statements}
#do{statements}while(conditiont)
#for(variable assignment ; condition;iteration process)
gawk '{
total=0
for(i = 1;i < 4;i++)
{
    total += $i
}
avg=total/3
print "Average:",avg
}' data5

#格式化打印%[modifier]control-letter
#%g 科学计数法和浮点数中较短的显示
#width 输出字段最小宽度数值 %6d
#prec 小数点后面位数 %.6f 
#-左对齐 %-6d
gawk '{
total=0
for(i = 1;i < 4;i++)
{
    total += $i
}
avg=total/3
printf "Average:%5.1f\n",avg
}' data5



#内建函数
#数学函数 atan2(x,y) cos(x) exp(x) int(x) log(x) rand() sin(x) sqrt(x) srand()
#字符串函数 目标字符串t 正则表达式r a数组
#asort(s[,d]) asorti(s[,d]) gensub(r,s,h[,t])
#gsub(r,s[,t]) index(s,t) length([s]) match(s,r,[,a]) split(s,a[,r])
#sprintf(format variables)
#sub(r,s[,t]) substr(s,i[,n]) tolower(s) toupper(s)
#时间函数 mktime(dataspec) strftime(format[,timestamp]) systime()


gawk '
BEGIN{FS=","}{
split($0,var)
print var[1],var[5]
}' data1

gawk 'BEGIN{
date=systime()
day=strftime("%A,%B %d, %Y",date)
print day
}' 

#自定义函数
gawk '
function myrand(limit)
{
    return int( limit * rand() )
}
BEGIN{
for(i = 1;i < 5;i++)print myrand(10)
}
'


#创建函数库funclib
gawk -f funclib -f script4 data2
