#########################################################################
# File Name: test28.sh
# Author: ma6174
# mail: ma6174@163.com
# Created Time: 2015年12月07日 星期一 14时21分31秒
#########################################################################
#!/bin/bash
# reading data from a file

count=1
cat test.sh| while read line
do 
    echo "Line $count: $line"
    count=$[ $count + 1 ]
done
echo "Finished processing the file"
