#########################################################################
# File Name: branch.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 16时23分22秒
#########################################################################
#!/bin/bash
#[address]b[label]

#跳过2和3行
sed '{2,3b ; s/This is/Is This/;s/line./test?/}' data2

#跳转到标签
sed '{/first/b jump1;s/This is the/No jump on/;:jump1;s/This is the/Jump here on/}' data2

#去掉逗号
echo "This,is,a,test,to,remove,commas."|sed -n '{:start;s/,//1p;/,/b start}'
