#!/bin/bash
s=0
max_port=22

if [ "$1" == 22 ]; then
    max_port=$1
fi

for i in $(seq -w 1 $max_port); do
	let a=$s+2
	let v6=$p+2
	if (( $i < 10 )); then
		as=0$i
	else
		as=$i
	fi
	echo "
protocol bgp client$i from PEERS {
        neighbor 10.0.55.$a as 655$as;
        source address 10.0.55.$(($s+1));
        export filter client_filter;
}
"
	let s+=4
done
