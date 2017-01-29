#!/bin/bash

# enum-domain.sh - enumerate a domain's hosts and emails and generate CSV files
# AC - 2017-01-19

# check if argument passed
if [[ ! -z "$1" ]]; then
    domain=$1 && echo "Scanning domain: $domain"
else
    echo "  enum-domain.sh - enumerate domain's hosts and emails."
    echo "      usage: $1 [domain]"
    echo "      No domain argument given."
    exit 1
fi

# run domain reconnaissance tools
fierce -th 32 -dns $domain -wordlist /usr/share/wordlists/dnsmap.txt -file fierce.$domain
theharvester -d $domain -l 1000 -b all -v theharvester.out | tee theharvester.$domain
	
# TODO add discover - https://github.com/leebaird/discover
# TODO add maltego
# TODO add shodan
# TODO add censys.io
# TODO add altDNS
# TODO and assetnote

touch $domain.hosts
touch $domain.emails

#### Email Enumeration
# extract emails only from domain, remove duplicates
grep '@$domain' theharvester.$domain | sort -uf >> $domain.emails
####

#### Host Enumeration
# extract hosts from fierce output , exclude the lines reporting subnet stats
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' fierce.$domain | grep -v 'hostnames found' | sed -e 's/\s\+/,/g' >> $domain.hosts

# extract hosts from theharvester
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' theharvester.$domain | tr ':' ' ' | sed -e 's/\s\+/,/g' >> $domain.hosts

# fold all uppercase to lower, remove duplicates, sort hosts by IPv4 subnets and remove trailing commas
cat $domain.hosts | tr '[:upper:]' '[:lower:]' | sort -uV | sed 's/[,.]$//' | grep $domain > $domain.hosts.tmp
mv $domain.hosts.tmp $domain.hosts
####
