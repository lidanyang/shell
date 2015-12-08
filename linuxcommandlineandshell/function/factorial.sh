#########################################################################
# File Name: factorial.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 10时25分07秒
#########################################################################
#!/bin/bash
# using recursion

function factorial {
    if [ $1 -eq 1 ]
    then
        echo 1
    else
        local temp=$[ $1 - 1 ]
        local result=`factorial $temp`
        echo $[ $result*$1 ]
    fi
}

result=`factorial 5`
echo $result
