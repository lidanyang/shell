while getopts xyz: arguments 2>/dev/null
do
    echo "OPTIND = $OPTIND"
    case $arguments in 
    x) echo "you entered -x ";;
    y) echo "you entered -y ";;
    z) echo "you entered -z "
       echo "\$OPTARG is $OPTARG."
       ;;
    \?) echo "Usage opts4[-xy][-z argument]"
        exit 1;;
    esac
done
echo "The number of arguments passed was $(($OPTIND - 1))"
