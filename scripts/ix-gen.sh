#!/bin/bash
max_port=22

if [ "$1" -gt 22 ]; then
    max_port=$1
fi

for i in $(seq 1 $max_port); do
	if (( $i < 10 )); then
		a=0$i
	else
		a=$i
	fi
	echo "
protocol bgp client$i from PEERS {
        neighbor 10.0.57.$i as 655$a;
        source address 10.0.57.254;
}
"
done
