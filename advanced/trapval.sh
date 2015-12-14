trap "rm tmp*;exit 1" 1 2 15
trap 2
trap "" 1 2
trap -
trap "trap 2" 2
read
