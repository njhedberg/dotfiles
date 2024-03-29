#!/bin/bash

OK=1

function findbin() {
    echo "Checking for $1"
    which $1 >/dev/null 2>&1
}

function checkbins() {
    while [[ $# > 0 ]]; do
        findbin $1 || red "$1 missing"
        shift
    done
}

function yellow() {
    echo -en "\033[1;33m"
    echo -n "$@"
    echo -e "\033[0m"
}

function red() {
    OK=0
    echo -en "\033[1;31m"
    echo -n "$@"
    echo -e "\033[0m"
}

checkbins git zsh vim tmux python3

if [ ! -z "$DISPLAY" ]; then
    checkbins xmonad xmobar dmenu feh xscreensaver
fi

# Check for font
FONT='terminus'
if [ `dpkg -S $FONT | wc -l` -ne 0 ]; then
    echo "Font $FONT found"
else
    red "Font $FONT missing"
    red "try: sudo apt install xfonts-terminus"
fi

##
## Finished!
##
echo
if [[ $OK == 1 ]]; then
    echo "No problems found."
    exit 0
else
    red "Diagnostic revealed errors"
    exit 1
fi
