#!/bin/bash


function usage
{
    echo -e "Usage:\t${0##*/} [-h] [-p] JSONFILE"
    echo -e "      \t-h: show this help menu"
    echo -e "      \t-p: print .content.passwd directly"
    exit 1
}

[ $# -eq 0 ] && usage

while getopts :ph OPT ; do
    case $OPT in
    p )
        PRINT_PASSWD=true
        ;;
    h )
        usage
        ;;
    \? )
        usage
    esac
done
shift $((OPTIND - 1))

[ ! -f "$1" ] && echo "error: file \"$1\" does not exist" && exit 1

! jq .content &>/dev/null < $1 && echo "error: file $1 must be json compliant and have a \"content\" attribute" && exit 1

DECONTENT=$(jq -r .content < $1 | base64 -d | gpg2 --decrypt 2>/dev/null)

[ -z "$DECONTENT" ] && echo "error: unsuccessful decryption, are you sure it's you?" && exit 1

if [ -n "$PRINT_PASSWD" ] ; then
    jq -r ".content = $DECONTENT | .content.passwd" < $1 | base64 -d ; echo
    exit 0
else
    jq ".content = $DECONTENT" < $1
    exit 0
fi

