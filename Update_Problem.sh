#!/bin/bash 
# Update_Problem - updates problem record in datebase

# Determine sql location & set variable

MYSQL=`which mysql`" Problem_Trek -u cbres"

# Obtain Record Id

if [ $# -eq 0 ]
then
    RECORDS_EXIST=`$MYSQL -Bse 'SELECT id_number FROM problem_logger 
    WHERE fixed_date="0000-00-00" OR prob_solutions=""'`

    if [ "$RECORDS_EXIST" != "" ]
    then
        echo 
        echo "The following record(s) need updating..."
        $MYSQL <<EOF
        SELECT id_number,report_date,prob_symptoms FROM problem_logger
            WHERE fixed_date="0000-00-00" OR prob_solutions=""\G

EOF
        fi 

        echo 
        echo "What is the ID number for the"
        echo -e "problem you want to update?:\c"
        read ANSWER
        ID_NUMBER=$ANSWER 
    else
        ID_NUMBER=$1
    fi 

echo
echo -e "Was the problem solved today?(y/n) \c"
read ANSWER 

case $ANSWER in 
    y|Y|YES|yes|Yes|yEs|yeS|YEs|yES)
        FIXED_DATE=`date +%y%m%d`
        ;;
    *)
        echo 
        echo "What was the date of resolution? [YYYYMMDD] \c"
        read ANSWER 

        FIXED_DATE=$ANSWER 
        ;;
esac
echo 
echo -e "Briefly describe the problem solution:\c"

read ANSWER 
PROB_SOLUTIONS=$ANSWER 

echo 
echo "Problem record updated as follows:"
echo 
$MYSQL<<EOF
UPDATE problem_logger SET
    prob_solutions="$PROB_SOLUTIONS",
    fixed_date=$FIXED_DATE 
    WHERE id_number=$ID_NUMBER;
SELECT * FROM problem_logger WHERE id_number=$ID_NUMBER\G
EOF

