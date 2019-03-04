#!/bin/bash
max_port=40
prefix=58

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
	echo "Usage: $0 ix1|ix2 [max ports]"
	exit
fi

if [[ $1 == 'ix1' ]]; then
	prefix=57
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
	echo "
protocol bgp ix_cli_$i from PEERS {
        neighbor       10.0.$prefix.$i as 655$a;
        source address 10.0.$prefix.254;
#		bfd;
}
"
done
