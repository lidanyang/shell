#!/bin/bash 
REPORT_FILE=`pwd`"/capture.csv"
TEMP_FILE=`pwd`"/capstats.html"
DATE=`date +%y/%m/%d.`
MAIL=`which mutt`
MAIL_TO=$USER

echo "<html><body><h2>Report for $DATE</h2>" > $TEMP_FILE
echo "<table border=\"1\">" >> $TEMP_FILE
echo "<tr><td>Date</td><td>Time</td><td>Users</td>" >> $TEMP_FILE
echo "<td>Load</td><td>Free Memory</td><td>%CPU Idle</td></tr>" >> $TEMP_FILE


cat $REPORT_FILE| gawk -F , '{
printf "<tr><td>%s</td><td>%s</td><td>%s</td>",$1,$2,$3;
printf "<td>%s</td><td>%s</td><td>%s</td>\n</tr>\n",$4,$5,$6;
}'>>$TEMP_FILE

echo "</table></body></html>" >> $TEMP_FILE
$MAIL -a $TEMP_FILE -s "Performance Report $DATE" -- $MAIL_TO < /dev/null 

# rm -f $TEMP_FILE


