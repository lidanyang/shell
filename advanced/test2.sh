trap 'echo "Control+C will not terminate $0."' 2
trap 'echo "Control+\ will not terminate $0."' 3
echo "Enter stop to quit shell"
while true
do
    echo -n "Go Go..."
    read 
    if [[ $REPLY == [sS]top ]]
    then
        break
    fi
done
