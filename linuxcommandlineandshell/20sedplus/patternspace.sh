#########################################################################
# File Name: patternspace.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 15时51分16秒
#########################################################################
#!/bin/bash
pattern space模式空间
hold space保持空间
h 模式空间复制到保持空间
H 模式附加到保持
g 保持复制到模式
G 保持附加到模式
x 交换模式和保持

sed -n '/first/{h;p;n;p;g;p}' data2
