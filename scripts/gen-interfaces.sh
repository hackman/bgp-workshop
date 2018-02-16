#!/bin/bash

case "$1" in
	tom)
		net=10.0.55
	;;
	jerry)
		net=10.0.66
	;;
	*)
		echo "Usage: $0 tom|jerry"
		exit 0
esac
	

# s is used to calculate subnets, it may be usefull further in the script
s=0
# starting ethernet interface(inside containers)
eth=10

max_port=22
if [ "$1" == 22 ]; then
    max_port=$1
fi

# Actual generation of Debian/Ubuntu interfaces configuration
for i in $(seq -w 1 $max_port); do
	a=$s
	let a++
	echo -e "auto eth$eth\niface eth$eth inet static\n\taddress ${net}.$a\n\tnetmask 255.255.255.252\n"
	let s+=4
	let eth++
done
