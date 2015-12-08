#########################################################################
# File Name: test.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 10时34分35秒
#########################################################################
#!/bin/bash
# using functions defined in a library file
. ./myfuncs 

value1=10
value2=5
result1=` addem $value1 $value2`
result2=` multem $value1 $value2`
result3=` divem $value1 $value2`
echo "The result of addem is : $result1"
echo "The result of multem is : $result2"
echo "The result of divem is : $result3"


