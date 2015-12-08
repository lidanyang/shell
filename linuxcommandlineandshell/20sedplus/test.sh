#########################################################################
# File Name: test.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 16时32分58秒
#########################################################################
#!/bin/bash

#未指定标签跳转到结尾
sed '{s/first/matched/;t;s/This is the/No match on/}' data2


sed -n '{:start;s/,//1p;t start}'
