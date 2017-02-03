#!/bin/bash
blurb="merge-hosts-entries.sh - collate all host discovery tool output and remove duplicates
            usage: $1 [domain]
            No domain argument given."

# AC - 2017-02-03

# check if argument passed
if [[ -z "$1" ]]; then
    echo $blurb
    exit 1
fi

domain=$1
cat *$domain.hosts  | grep $domain | tr '[:upper:]' '[:lower:]' | sort -uV | sed 's/[,.]$//' | tee $domain.hosts
echo "-- Summary --"
wc -l *$domain.hosts
