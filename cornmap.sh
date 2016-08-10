#!/bin/bash
echo "cornmap.sh - fast, thorough TCP & UDP unicornscan output to nmap."
host=''
ipf='.host.ip'

# use the .host.ip file in working directory to get host name
if [[ -f $ipf ]]; then
    host=$(cat $ipf) && echo "$ipf found: $host"
elif [[ ! -z "$1" ]]; then
    host=$1 && echo "Scanning host: $host"
else
    echo "  usage: cornmap [host]"
    echo "  No host argument given or file '$ipf' in current directory."
    exit 1
fi

mkdir .cornmap
path=".cornmap/$host"
set -x
# do a full TCP unicornscan: -mT TCP -E error reporting -B src_port (DNS)
# TODO: determine unicorn can handle parallel UDP scan on same host? 
# unicornscan -v -mT -E -B 53 $host:a > $path.tcp.out
unicornscan -v -mT -E $host:a > $path.tcpuc.out
set +x

# exctract tcp port results and put into nmap format for OS detect, banner grab
grep 'TCP open' $path.tcpuc.out > $path.tcp.out
rm $path.tcpuc.out
tcp_ports=$(grep -o '\[\s*[0-9]*\]' $path.tcp.out | grep -o '[0-9]*')
if [[ ! -z "$tcp_ports" ]]; then
    tcp_ports=$(printf "%s," $tcp_ports);
    set -x
    nmap -v -Pn -A -pT:$tcp_ports $host > $path.tcpnm.out &
    set +x
else
    echo "$host: no open TCP ports found."
fi

# as above for UDP
unicornscan -v -mU -E $host:a > $path.udpuc.out
grep 'UDP open' $path.udpuc.out > $path.udp.out
rm $path.udpuc.out
udp_ports=$(grep -o '\[\s*[0-9]*\]' $path.udp.out | grep -o '[0-9]*')
udp_ports=$(printf "%s," $udp_ports | sed 's/,$//');
set -x
nmap -v -Pn -sU -A -pU:$udp_ports $host > $path.udpnm.out &
set +x

echo "Putting tcp and udp results togther..."
cat $path.tcpnm.out $path.udpnm.out > cornmap-$host.out
echo "Finished cornmap scan."
exit 0