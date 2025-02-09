#!/bin/bash

ISTAG=""
ISNAME=""
ISUSER=""
COMPACT=""
ATTRIBUTE_FILTER=""
ROOTDIR=/home/alberto/passwd

function usage
{
    echo -e "Usage:\t${0##*/} [-h] [-c] -t TAG|-n NAME|-u USER"
    echo -e "      \t-h: show help"
    echo -e "      \t-c: compact: only show name and filename"
    echo -e "      \t-t: any one of the tags contains the TAG substring"
    echo -e "      \t-n: the name contains the NAME substring"
    echo -e "      \t-u: the subject contains the USER substring"
    exit 1
}

[ $# -eq 0 ] && usage

while getopts :ct:n:u: OPT ; do
    case $OPT in
    h )
        usage
        ;;
    c )
        COMPACT=true
        ;;
    t )
        ISTAG=true
        TAG=$OPTARG
        ;; 
    n)
        ISNAME=true
        NAME=$OPTARG
        ;;
    u)
        ISUSER=true
        USER=$(echo -n $OPTARG | tr '[:upper:]' '[:lower:]')
        ;;
    \? )
        usage
    esac
done
shift $((OPTIND - 1))

[ $# -gt 0 ] && usage

[ -n "$COMPACT" ] && \
FILTER=' | map({"name":.name,"filename":.filename})' CENSOR="" || \
FILTER="" CENSOR=' | map(.content = "XXXXXXXXXXXX")'

[ -n "$ISTAG" ] && ATTRIBUTE_FILTER=$ATTRIBUTE_FILTER' | map(select(.tags | any(contains("'"$TAG"'"))))'
[ -n "$ISNAME" ] && ATTRIBUTE_FILTER=$ATTRIBUTE_FILTER' | map(select(.name | contains("'"$NAME"'")))'
[ -n "$ISUSER" ] && ATTRIBUTE_FILTER=$ATTRIBUTE_FILTER' | map(select(.subject | ascii_downcase | contains("'"$USER"'")))'

bash -c "find $ROOTDIR -name \"*.json\" -type f -exec cat {} \; | jq -s ."\'"$ATTRIBUTE_FILTER$FILTER$CENSOR"\'
