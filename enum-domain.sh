#!/bin/bash

# AC - 2017-01-19
# enum-domain.sh - enumerate a domain's hosts and emails and generate CSV files

# check if argument passed
if [[ ! -z "$1" ]]; then
    domain=$1 && echo "Scanning domain: $domain"
else
    echo "  enum-domain.sh - enumerate domain's hosts and emails."
    echo "      usage: $1 [domain]"
    echo "      No domain argument given."
    exit 1
fi
 
# run DNS reconnaissance tools
fierce -th 32 -dns $domain -wordlist /usr/share/wordlists/dnsmap.txt -file fierce.$domain
theharvester -d $domain -l 1000 -b all -v theharvester.out | tee theharvester.$domain

# TODO add discover - https://github.com/leebaird/discover
# TODO add shodan
# TODO add censys.io
# TODO add shubs wakelam tool altDNS
# TODO and assetnote

touch $domain.hosts
touch $domain.emails

# extract hosts from fierce output , exclude the lines reporting subnet stats
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' fierce.$domain | grep -v 'hostnames found' | sed -e 's/\s\+/,/g' >> $domain.hosts
# TODO remove trailing '.' and ',' from domain entries

# extract hosts from theharvester
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' theharvester.$domain | tr ':' ' ' | sed -e 's/\s\+/,/g' >> $domain.hosts
# extract emails, remove theharvester author's email
grep '@$domain' theharvester.$domain >> $domain.emails

# sort hosts by IP subnets
sort -uV $domain.hosts | grep $domain > $domain.hosts.tmp
mv $domain.hosts.tmp $domain.hosts
