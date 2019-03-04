#!/bin/bash
s=0
prefix=56
max_port=40

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
	echo "Usage: $0 tom|jerry [max ports]"
	exit
fi

if [[ $1 == 'tom' ]]; then
	prefix=55
fi

if [[ -n $2 ]]; then
    max_port=$2
fi

for as in $(seq -w 1 $max_port); do
	let a=$s+2
	let v6=$p+2
	if [[ $max_port -lt 10 ]]; then
		as=$(printf "%02d" $as)
	fi
	echo "
protocol bgp isp_cli_$as from PEERS {
	neighbor 10.0.${prefix}.$a as 655$as;
	source address 10.0.${prefix}.$(($s+1));
#	bdf;
}
"
	let s+=4
done
