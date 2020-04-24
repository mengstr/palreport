#!/bin/bash

#
# palreport.sh - Lists the sizes of all functions in a PDP-8 pal file
# For more info see https://github.com/SmallRoomLabs/palreport
#
# Copyrght (c) 2020 Mats Engstrom - released under the MIT licnese
#

reAz='[a-zA-Z]'
re09='^[0-9]+$'
mode=1

while IFS= read -r line; do

    # Scan lines for the start marker
    if [ "$mode" == "1" ]; then
        tmp="${line:19:2}"
        if [ "$tmp" == "/[" ]; then
            mode=2
            continue
        fi
    fi

    # Scan until a label is found, when the label is found 
    # we'll fall through to the next test since the label might
    # be compined with a opcode on the same line
    if [ "$mode" == "2" ]; then
        tmp="${line:19:1}"
        if [[ $tmp =~ $reAz ]]; then 
            LABEL=$(echo "${line:19:6}" | sed 's/[^A-Za-z0-9].*//')
            mode=3
        fi
    fi

    # Scan until we find an address, this indicates that we have an
    # opecode and we're in the code-part of the function.
    if [ "$mode" == "3" ]; then
        tmp="${line:6:5}"
        if [[ $tmp =~ $re09 ]]; then 
            ADDR1=$(echo $tmp | sed 's/^0*//')
            ADDR2=$ADDR1
            mode=4
            continue
        fi
    fi

    # Scan until the end marker, but while doing that update the
    # last address variable as we encounter addresses.
    if [ "$mode" == "4" ]; then
        tmp="${line:6:5}"
        if [[ $tmp =~ $re09 ]]; then 
            ADDR2=$(echo $tmp | sed 's/^0*//')
        fi
        tmp="${line:19:2}"
        if [ "$tmp" == "/]" ]; then
            hole=$(( $((8#$ADDR1)) - $((8#$ADDR2HOLD))  - 1 ))
            if [ "$hole" -gt 0 ] && [ "$ADDR2HOLD" != "" ]; then printf " followed by %d unused bytes" $hole; fi
            printf "\n" 
            printf "%04d  %-6s %4d bytes"  $ADDR1 $LABEL $(( $((8#$ADDR2)) - $((8#$ADDR1)) + 1 )) 
            ADDR2HOLD=$ADDR2
            LABEL=""
            ADDR1=""
            ADDR2=""
            mode=1
            continue
        fi
    fi
done
printf "\n" 
