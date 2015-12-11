#########################################################################
# File Name: archive.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月11日 星期五 15时25分13秒
#########################################################################
#!/bin/bash
# Hourily_Archive designated files & directories

# gather Current Date
DAY='date +%d'
MONTH='date +%m'
TIME='date +%k%M'

# set Archive File Name
FILE=archive$DATE.tar.gz

# set Configuration and Destination File
CONFIG_FILE=/home/user/archive/hourly/Files_To_Backup
BASEDEST=/home/user/archive/hourly 

# Create Archive Destination Directory
mkdir -p $BASEDEST/$MONTH/$DAY

# Build Archive Destination File Name 
DESTINATION=$BASEDEST/$MONTH/$DAY/archive$TIME.tar.gz

########## MAIN SCRIPT ##########
# Check Backup Config file exists 
if [ -f $CONFIG_FILE] #Make sure the config file still exists.
then 
    echo
else
    echo
    echo "$CONFIG_FILE does not exist."
    echo "Backup not completed due to missing Configuration File"
    echo
    exit
fi 

# Build the names of all the files to backup.
FILE_NO=1 #Start on Line 1 of Config File.
exec<$CONFIG_FILE

read FILE_NAME

while [ $? -eq 0 ]
do 
    # Make sure the file or directories exists.
    if [ -f $FILE_NAME -o -d $FILE_NAME ]
    then 
        FILE_LIST="$FILE_LIST $FILE_NAME"
    else
        echo
        echo "$FILE_NAME , does not exist."
        echo "Obviously , I will not include it in this archive."
        echo "It is listed on line $FILE_NO of the config file."
        echo "Continuing to build archive list..."
        echo 
    fi 

    FILE_NO=$[ $FILE_NO + 1 ]
    read FILE_NAME
done

# Back_up the files and compress archive.sh
tar -czf $DESTINATION $FILE_LIST 2>/dev/null 



