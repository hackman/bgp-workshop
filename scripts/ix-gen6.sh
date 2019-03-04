#!/bin/bash
max_port=40
prefix=8003
net=2001:7fc:21bc

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
	echo "Usage: $0 ix1|ix2 [max ports]"
	exit
fi

if [[ $1 == 'ix1' ]]; then
	prefix=8002
fi

if [[ -n $2 ]]; then
    max_port=$1
fi

for i in $(seq 1 $max_port); do
	if (( $i < 10 )); then
		a=0$i
	else
		a=$i
	fi
	v6=$(printf "%x" $i)
	echo "
protocol bgp ix_cli6_$i from PEERS {
        neighbor       $net:$prefix::$v6 as 655$a;
        source address $net:$prefix::fffe;
#		bfd;
}
"
done
