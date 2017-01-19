# AC - 2017-01-19
# enumerate a domain's hosts and emails and generate CSV files
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

touch $domain.ips
touch $domain.emails

# extract hosts from fierce output , exclude the lines reporting subnet stats
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' fierce.$domain | grep -v 'hostnames found' | sed -e 's/\s\+/,/g' >> $domain.hosts

# TODO
# TODO remove trailing '.' and ',' from domains entries
# TODO

# extract hosts from theharvester
grep -E '[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}' theharvester.$domain | tr ':' ' ' | sed -e 's/\s\+/,/g' >> $domain.hosts
# extract emails
grep '@' theharvester.$domain >> $domain.emails

# sort hosts by IP subnets
sort -uV $domain.hosts > $domain.hosts.tmp
mv $domain.hosts.tmp $domain.hosts
