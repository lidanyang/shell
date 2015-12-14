#!/bin/bash 

MYSQL=`which mysql`" Problem_Trek -u cbres"

ID_NUMBER=`date +%y%m%d%H%M`
REPORT_DATE=`date +%y%m%d`

echo

echo -e "Briefly describe the problem & its symptoms: \c"

read ANSWER
PROB_SYPTOMS=$ANSWER

FIXED_DATE=0
PROB_SOLUTIONS=""

echo 
echo "Problem recorded as follows:"
echo 

$MYSQL <<EOF
INSERT INTO problem_logger VALUES(
    $ID_NUMBER,
    $REPORT_DATE,
    $FIXED_DATE,
    "$PROB_SYPTOMS",
    "$PROB_SOLUTIONS");

SELECT * FROM problem_logger WHERE id_number=$ID_NUMBER \G
EOF
