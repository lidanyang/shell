#########################################################################
# File Name: return.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 09时36分08秒
#########################################################################
#!/bin/bash
# using the return command in a function

function db1 {
    read -p " Enter a value: " value
    echo "doubling the value"
    return $[ $value*2 ]
}

db1
echo "the new value is $?"
