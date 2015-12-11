#########################################################################
# File Name: Delete_User.sh
# Author: ldy
# mail: lidanyang334@163.com
# Created Time: 2015年12月11日 星期五 15时51分07秒
#########################################################################
#!/bin/bash
# Delete_User - Automates the 4 steps to remove an account

#########################################################################
# Define Functions
#
#########################################################################

function get_answer {
    #
    unset ANSWER
    ASK_COUNT=0
    #
    while [ -z "$ANSWER" ] #while no answer is given. keep asking
    do
        ASK_COUNT=$[ $ASK_COUNT + 1 ]
        #
        case $ASK_COUNT in #if user gives no answer in time allocated
            2)
                echo 
                echo "Please answer the question."
                echo
                ;;
            3)
                echo 
                echo "One last try...please answer the question"
                echo
                ;;
            4)
                echo 
                echo "Since you refuse to answer the question..."
                echo "exiting program."
                echo
                exit
                ;;
        esac
        
        echo 

        if [ -n "$LINE2" ]
        then
            echo $LINE1
            echo -e $LINE2" \c"
        else
            echo -e $LINE1" \c"
        fi 
        
        # Allow 60 seconds to answer before time-out
        read -t 60 ANSWER
    done

    # Do a little variable clean-up
    unset LINE1
    unset LINE2
}

#########################################################################

function process_answer {
case $ANSWER in 
    y|Y|n|N|yes|Yes|yEs|yeS|YEs|yES)
        ;;
    *)
        echo
        echo $EXIT_LINE1
        echo $EXIT_LINE2
        echo 
        exit 
        ;;
esac

unset EXIT_LINE1
unset EXIT_LINE2
}
#########################################################################
# Get name of User Account to check
#
############## Main Script ##############

echo "Step #1 - Determine User Account name to Delete"
echo 
LINE1="Please enter the username "
LINE2="account you wish to delete from the system:"
get_answer
USER_ACCOUNT=$ANSWER

LINE1="Is $USER_ACCOUNT the user account "
LINE2="you wish to delete from the system? [y/n] "
get_answer

EXIT_LINE1="Because the account. $USER_ACCOUNT , is not "
EXIT_LINE2="the one you wish to delete. we are leaving the script..."
process_answer

USER_ACCOUNT_RECORD=$(cat /etc/passwd | grep -w $USER_ACCOUNT)
if [ $? -eq 1 ]
then
    echo "Account , $USER_ACCOUNT not found."
    echo "leaving the script..."
    exit 
fi 

echo 
echo "I found this record:"
echo $USER_ACCOUNT_RECORD

LINE1=" Is this the correct User Account? [y/n]"
get_answer



EXIT_LINE1="Because the account. $USER_ACCOUNT. is not"
EXIT_LINE2="the one you wish to delete . We are leaving the script..."
process_answer

echo
echo "Step #2 - Find process on system belonging to user account"
echo 
echo "$USER_ACCOUNT has the following process running:"
echo

ps -u $USER_ACCOUNT

case $? in 
    1)
        echo "There are no processes for this account currently running."
        echo
        ;;
    0)
        unset ANSWER 
        LINE1="Would you like me to kill the process(es)? [y/n]"
        get_answer
        #
        case $ANSWER in 
            y|Y|n|N|yes|Yes|yEs|yeS|YEs|yES)
                echo
                trap "rm $USER_ACCOUNT_Running_Process.rpt" SIGTERM SIGINT SIGQUIT
                ps -u $USER_ACCOUNT > $USER_ACCOUNT_Running_Process.rpt

                exec < $USER_ACCOUNT_Running_Process.rpt
                read USER_PROCESS_REC # First record will be blank
                read USER_PROCESS_REC

                while [ $? -eq 0 ]
                do
                    USER_PID=$(echo $USER_PROCESS_REC|cut -d " " -f1)
                    kill -9 $USER_PID
                    echo "Killed process $USER_PID"
                    read USER_PROCESS_REC
                done
                rm $USER_ACCOUNT_Running_Process.rpt
                ;;
            *)
                echo 
                echo "Will not kill process(es)"
                echo
                ;;
        esac
        ;;
esac

echo 
echo "Step #3 - Find files on system belonging to useri account" 
echo
echo "Createding a report of all files owned by $USER_ACCOUNT."
echo
echo "It's recommended that you backup/archive these files."
echo "and then do one of the two things:"
echo " 1) Delete the files"
echo " 2) Change the files ownership to a current user account."
echo
echo "Please wait. This may take a while..."

REPORT_DATE=`date +%y%m%d`
REPORT_FILE=$USER_ACCOUNT"_Files_"$REPORT_DATE".rpt"

sudo find / -user $USER_ACCOUNT > $REPORT_FILE 2>/dev/null 
echo
echo "Report is complete."
echo "Name of report:       $REPORT_FILE"
echo "Location of report:      `pwd`"
echo
 
echo 
echo "Step #4 - remove user account"
echo

unset ANSWER
LINE1="Do you wish to remove $USER_ACCOUNT's account from system? [y/n]"
get_answer

EXIT_LINE1="Since you don't wish to remove user account."
EXIT_LINE2="$USER_ACCOUNT at this time. exiting the script..."
process_answer


userdel $USER_ACCOUNT
echo 
echo "User account, $USER_ACCOUNT ,has been removed"
echo



