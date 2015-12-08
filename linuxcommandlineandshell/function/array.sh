#########################################################################
# File Name: array.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 09时54分32秒
#########################################################################
#!/bin/bash
# array variable to function test
myarray=(1 2 3 4 5)

function testit {
    local newarray
    newarray=(`echo "$@"`)
    echo "The new array value is:${newarray[*]}"
}

echo "The original array is ${myarray[*]}"
testit ${myarray[*]}


myarray=(1 2 3 4 5)
#从函数返回数组
function test2 {
    local newarray
    local oriarray
    oriarray=(`echo "$@"`)
    newarray=(`echo "$@"`)
    i=0
    elements=$[ $# - 1 ]
    echo ${oriarray[*]}
    for(( i=0;i < elements;i++))
    {
        newarray[$i]=$[ ${oriarray[$i]}*2 ]
        echo ${newarray[$i]}
    }
   # do
 #       newarray[$i]=$[ $var*2 ]
  #      i=$[ $i + 1 ]
    #done
    #echo ${newarray[*]}
}

echo "The original is ${myarray[*]}"
#test2 ${myarray[*]}
arg1=`echo ${myarray[*]}`
test2 $arg1
#result=(`test2 $arg1`)
#echo "The new array is : ${result[*]}"




