#########################################################################
# File Name: base.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月08日 星期二 09时29分41秒
#########################################################################
#!/bin/bash
func1(){
    echo "trying to display a non-existent file"
    ls -l badfile
}

echo "testing"

func1

echo "The exit status is $?"

func2(){
    ls -l badfile
    echo "trying to display a non-existent file"
}

echo "testing"

func2

echo "The exit status is $?"
