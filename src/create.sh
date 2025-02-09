#!/bin/bash

CLEANUP=true
FBSMROOTDIR=${FBSMROOTDIR:-/home/alberto/passwd}
FBSMRECIPIENT=${FBSMRECIPIENT:-rafaellarios@eclipso.eu}

function usage
{
    echo -e "Usage:\t${0##*/} [-h] [-d] INPUTFILE"
    echo -e "      \t-h: show help"
    echo -e "      \t-d: dirty: don't clean input file"
    exit 1
}

[ $# -eq 0 ] && usage

while getopts :hd OPT ; do
    case $OPT in
    h )
        usage
        ;;
    d )
        CLEANUP=""
        ;;
    \? )
        usage
    esac
done
shift $((OPTIND - 1))

if [ $# -ne 1 ] || [ ! -f $INPUTFILE ] ; then
    usage
else

    INPUTFILE=$1
    OUTPUTFILE=$(jq -r '.shown.filename' $INPUTFILE)

    if [ -z "$OUTPUTFILE" ] ; then
       echo 'error: there must be a child attribute called "filename" under "shown"'
       exit 1
    elif [ "${OUTPUTFILE%%/*}" == "templates" ] ; then
       echo 'error: "templates" directory is reserverved for templates'
       exit 1
    fi
    
    if ! jq -e .shown,.hidden &>/dev/null < $INPUTFILE ; then
        echo -e 'error: the input file should be json compliant and have a "shown" and "hidden" attributes'
        exit 1
    fi

    [ $OUTPUTFILE != ${OUTPUTFILE##*/} ] && \
    [ $(readlink -f ${OUTPUTFILE%/*}) != $(readlink -f $FBSMROOTDIR) ] && \
    echo "error: all files will be saved to $FBSMROOTDIR, no other directory is allowed"  && \
    exit 1

    [ -f $FBSMROOTDIR/${OUTPUTFILE##*/} ] && \
    echo -e "error: there's already a file named ${OUTPUTFILE##*/} in $FBSMROOTDIR" && \
    exit 1

    jq ".shown | .content = \"$(jq .hidden $INPUTFILE | gpg2 --recipient $FBSMRECIPIENT --encrypt | base64 -w0)\"" $INPUTFILE > $FBSMROOTDIR/${OUTPUTFILE##*/}

    if [ -n "$CLEANUP" ] ; then
        CLEANFILE=$(jq ".hidden = $(jq '.hidden | to_entries | map(.value = null) | from_entries' $INPUTFILE)" $INPUTFILE | \
        jq '.shown.content = null | .shown.filename = null | .shown.name = null | .shown.tags = []' | base64 -w0)
        echo $CLEANFILE | base64 -d > $INPUTFILE
    fi
fi

