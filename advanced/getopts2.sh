while getopts xy options 2>/dev/null
do 
    case $options in
    x) echo "you enter x";;
    y) echo "you enter y";;
    \?) echo "Only -x and -y are valid options" 1>&2
esac
done
