#!/bin/bash

case "$1" in
	tom)
		net=10.0.55
		net6=2001:67c:21bc:8000::1:
		prefix=3
	;;
	jerry)
		net=10.0.56
		net6=2001:67c:21bc:8001::1:
		prefix=4
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
	echo -e "
auto eth${prefix}$i
iface eth${prefix}$i inet static
	address ${net}.$a
	netmask 255.255.255.252

iface eth${prefix}$i inet6 static
	address ${net6}:$a
	prefix  126
"
	let s+=4
	let eth++
done
