#!/bin/bash

FBSMROOTDIR=${0%/*}/..
echo -en "Enter your gpg recipient: " && read RECIPIENT
FBSMRECIPIENT=$(echo $RECIPIENT)

cat << heredoc >> ~/.bashrc
# START: Added by file-based-secret-manager https://github.com/ralberrto/file-based-secret-manager
export FBSMROOTDIR=$FBSMROOTDIR
export FBSMRECIPIENT=$FBSMRECIPIENT
export PATH=\$PATH:$(readlink -f ${0%/*}/../bin)
# END: Added by file-based-secret-manager https://github.com/ralberrto/file-based-secret-manager

heredoc
