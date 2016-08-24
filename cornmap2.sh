#!/bin/bash
echo "  cornmap2.sh - complete TCP & UDP nmap scan riding on the back of unicornscan."
host=''
ipf='.host.ip'
timenow=$(date +%Y%m%d_%H%M%S)

if [[ ! -z "$1" ]]; then
    host=$1 && echo "Scanning host: $host"
else
    echo "  usage: cornmap HOST" && exit 1
fi

dir=".cornmap"
mkdir $dir
path="$dir/$host"

ptouch() {
  for p in "$@"; do
    _dir="$(dirname -- "$p")"
    [ -d "$_dir" ] || mkdir -p -- "$_dir"
    touch -- "$p"
  done
}

scan() {
    type=$1
    
    case "$type" in
            "tcp")
                flag='T'
                ;;
             
            "udp")
                flag='U'
                nmap_flags="-sU"
                ;;
             
            *)
                echo "Should never get here."
                exit 1
    esac

    # paths for tcp and udp unicornscan and nmap output
    pre=$path.$type
    f1=$pre.ucout
    f2=$pre.out
    f3=$pre.nmout
    lckpath=$pre/lck/
    flck=$lckpath$type.lck
    
    ptouch $flck
    set -x
    # full TCP unicornscan: -mT/U TCP/UDP -E error reporting -B src_port (DNS)
    unicornscan -v -m$flag -E $host:a > $f1
    set +x

    # exctract port results and put into nmap format for OS detect, banner grab
    grep 'TCP open' $f1 > $f2
    rm $f1
    ports=$(grep -o '\[\s*[0-9]*\]' $f2 | grep -o '[0-9]*')
    if [[ ! -z "$ports" ]]; then
        ports=$(printf "%s," $ports);
        set -x
        nmap -v -Pn -A $nmap_flags -p"$flag":$ports $host > $f3
        set +x
    else
        echo "$host: no open $type ports found."
    fi
    rm $flck
}

scan tcp &
scan udp &

sleep 1

printf "Scanning"
while [ "$(ls -A $lckpath)" ]; do
    printf "."
    sleep 5;
done

echo "Putting tcp and udp results togther..."
cat $path.tcpnm.out $path.udpnm.out > $host-$timenow.cornmap.out
echo "Finished cornmap scan."
exit 0
