#!/bin/bash
s=0
prefix=4
max_port=40

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
	echo "Usage: $0 tom|jerry [max ports]"
	exit
fi

if [[ $1 == 'tom' ]]; then
	addr6=2001:7fc:21bc:8000::1:
	prefix=3
fi

if [[ -n $2 ]]; then
    max_port=$2
fi

for as in $(seq -w 1 $max_port); do
	let a=$s+2
	let v6=$p+2
	src=$(printf "%x" $(($s+1)))
	dst=$(printf "%x" $a)
	
	echo "
protocol bgp isp_cli6_$as from PEERS {
	neighbor       ${addr6}$dst as 655$as;
	source address ${addr6}$src;
#	bdf;
}
"
	let s+=4
done
