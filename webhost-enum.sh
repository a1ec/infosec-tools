#!/bin/bash

# webhost-enum.sh - runs a bunch of scripts on a web host
blurb="  enum-domain.sh - enumerate domain's hosts and emails.\
         usage: $1 [domain]      
         No domain argument given."
# AC - 2017-02-08

# check if argument passed
if [[ -z "$1" ]]; then
    echo $blurb
    exit 1
fi

vhost=$1
URL=https://$vhost && echo "Scanning URL: $URL"

# verbose, auto send updates, auto filename
nikto -host $URL -vhost $vhost -nointeractive -ask auto -output nikto.$vhost.html # .html also

# brute force directories
dirsearch.py -u $URL -e html -w /usr/share/wordlists/dirbuster/directory-list-2.3-medium.txt -t 50 --plain-text-report=dirsearch.$vhost
