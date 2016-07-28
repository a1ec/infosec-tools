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

path="/tmp/$host"
set -x
# do a full TCP unicornscan: -mT TCP -E error reporting -B src_port (DNS)
# TODO: determine unicorn can handle parallel UDP scan on same host? 
unicornscan -v -mT -E -B 53 $host:a > $path.tcp-unicornscan.out
set +x

# exctract tcp port results and put into nmap format for OS detect, banner grab
grep 'TCP open' $path.tcp-unicornscan.out > $path.tcpopen.out
tcp_ports=$(grep -o '\[\s*[0-9]*\]' $path.tcpopen.out | grep -o '[0-9]*')
if [[ ! -z "$tcp_ports" ]]; then
    tcp_ports=$(printf "%s," $tcp_ports); echo tcp_ports:$tcp_ports
    tcp_ports=T:$tcp_ports
    set -x
    nmap -v -Pn -A -pT:$tcp_ports $host > $path.tcpnmap.out &
    set +x
else
    echo "$host: no open TCP ports found."
fi

# as above for UDP
unicornscan -v -mU -E -B 53 $host:a > $path.udp-unicornscan.out
grep 'UDP open' $path.udp-unicornscan.out > $path.udpopen.out
udp_ports=$(grep -o '\[\s*[0-9]*\]' $path.udpopen.out | grep -o '[0-9]*')
udp_ports=$(printf "%s," $udp_ports | sed 's/,$//'); echo udp_ports:$udp_ports
set -x
nmap -v -Pn -sU -A -pU:$udp_ports $host > $path.udpnmap.out &
set +x

cat $path.tcpnmap.out $path.udpnmap.out > nmap-alludptcp.out
echo "Finished cornmap scan."
exit 0
