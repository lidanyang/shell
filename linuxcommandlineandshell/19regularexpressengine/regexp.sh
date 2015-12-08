#########################################################################
# File Name: regexp.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 14时19分45秒
#########################################################################
#!/bin/bash

echo "This is a test"|sed -n '/test/p'
echo "This is a test"|gawk -n '/test/{print $0}'


sed -n '/\//p'
sed '/^$/d' data #删除空白行
sed -n '/regular.*expression/p' 匹配任意多个任意字符
sed -n '/[ae]*t/p' 匹配任意多个区间

#gawk --re-interval 指定识别正则表达式区间
