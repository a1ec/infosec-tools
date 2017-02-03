#!/bin/bash

# enum-domain.sh - attempts to enumerate a domain's hostnames, IPv4s and emails
# AC - 2017-01-19

# Runs the tools, filter output to simple newline separated entries, merge

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
echo "Have you run recon-ng, maltego, dnsdumpster and exported CSV results?"; sleep 2
fierce -th 32 -dns $domain -wordlist /usr/share/wordlists/dnsmap.txt -file fierce.$domain
theharvester -d $domain -l 1000 -b all -v theharvester.out | tee theharvester.$domain

# TODO add discover - https://github.com/leebaird/discover
# TODO add recon-ng
# TODO add censys.io
# TODO and assetnote

################
# theharvester #
################
# extract hosts
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' theharvester.$domain | tr ':' ' ' | sed -e 's/\s\+/,/g' > theharvester.$domain.csv
cut -d, -f1 theharvester.$domain.csv | sort -uV | tee theharvester.$domain.ipv4s
cut -d, -f2 theharvester.$domain.csv | grep $domain | tr '[:upper:]' '[:lower:]' | sort -uV | tee theharvester.$domain.hosts
# extract emails only from domain, remove duplicates, ignore case
grep @$domain theharvester.$domain | sort -uf | tee theharvester.$domain.emails

###########
# maltego #
###########
# TODO run maltego manually, enter domain, run machine and export to CSV
grep $domain maltego.$domain | cut -d, -f2 | sort -uV | tee maltego.$domain.tmp
cat maltego.$domain* | cut -d, -f1 | grep $domain | grep -v '@$domain' | tr '[:upper:]' '[:lower:]' | sort -uV | tee maltego.$domain.hosts
grep @$domain maltego.$domain* | cut -d',' -f2 | cut -d':' -f2 | sort -uf | tee maltego.$domain.emails

##########
# fierce #
##########
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' fierce.$domain | grep -v 'hostnames found' | sed -e 's/\s\+/,/g' | cut -d, -f1 | sort -uV | tee fierce.$domain.ipv4s
grep $domain fierce.$domain | grep -v 'hostnames found' | sed -e 's/\s\+/,/g' | cut -d, -f2 | sort -uf | tee fierce.$domain.hosts

############
# recon-ng #
############
# TODO run recon-ng with domain input and script
cut -d, -f1 recon-ng.$domain | tr -d '"' | tee recon-ng.$domain.hosts
cut -d, -f2 recon-ng.$domain | tr -d '"' | sort -uV | tee recon-ng.$domain.ipv4s

###############
# dnsdumpster #
###############
# TODO curl requests for domain at https://dnsdumpster.com
# TODO download xlsx and convert to CSV 
cut -f1 dnsdumpster.$domain | sort -u | tee dnsdumpster.$domain.hosts
cut -f2 dnsdumpster.$domain | sort -uV | tee dnsdumpster.$domain.ipv4s

##########
# altdns #
##########
# run altdns after collecting all other results to seed permutations
cat *$domain.hosts  | grep $domain | tr '[:upper:]' '[:lower:]' | sort -uV | sed 's/[,.]$//' | tee $domain.hosts
wordlist=/usr/share/wordlists/altdns-words.txt
altdns.py -i $domain.hosts -o altdns.$domain.list -w $wordlist -r -s altdns.$domain -t 64
cut -d':' -f1 altdns.$domain | tee altdns.$domain.hosts

# Merge all tool output
# fold all uppercase to lower, remove duplicates, sort hosts by IPv4 subnets and remove trailing commas
cat *$domain.hosts  | grep $domain | tr '[:upper:]' '[:lower:]' | sort -uV | sed 's/[,.]$//' | tee $domain.hosts
cat *$domain.emails | grep $domain | tr '[:upper:]' '[:lower:]' | sort -uV | sed 's/[,.]$//' | tee $domain.emails
cat *$domain.ipv4s  | sort -uV  | tee $domain.ipv4s
