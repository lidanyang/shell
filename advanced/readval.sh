#!/bin/bash 

read answer
echo "answer = $answer"

read first last 
echo "first = $first last = $last"

read 
echo $REPLY

read -a friends
echo "I have ${#friends} friends"
echo "They are ${friends[0]},${friends[1]},${friends[2]}."
echo ${friends[*]}

read -e -p "enter value:"
echo $REPLY

read -r line
echo $line



