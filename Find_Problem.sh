#!/bin/bash 
MYSQL=`which mysql`" Problem_Trek -u cbres "
# Obtain Keyword(s)
if [ -n "$1" ] 
then
    KEYWORDS=$@
else
    echo
    echo "What keywords would you like to search for?"
    echo -e "Please separate words by a space: \c"
    read ANSWER
    KEYWORDS=$ANSWER
fi


# Find problem record

echo 
echo "The following was found using keywords: $KEYWORDS"
echo

KEYWORDS=`echo $KEYWORDS|sed 's/ /|/g'`

$MYSQL << EOF
SELECT * FROM problem_logger WHERE prob_symptoms REGEXP '($KEYWORDS)'
    OR
    prob_solutions REGEXP '($KEYWORDS)'\G
EOF
