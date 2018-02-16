#!/bin/bash

tom_vlan=300
tom_v4=10.0.55
tom_v6=2001:67c:21bc:8000::1:
jerry_vlan=400
jerry_v4=10.0.56
jerry_v6=2001:67c:21bc:8000::2:
ix1_vlan=500
ix1_v4=10.0.57
ix1_v6=2a02:5220::aa:
ix1_ipv4=10.0.57.254
ix1_ipv6=2a02:5220::aa:ff
ix2_vlan=600
ix2_v4=10.0.58
ix2_v6=2a02:5220::bb:
ix2_ipv4=10.0.58.254
ix2_ipv6=2a02:5220::bb:ff
public_v4=77.104.185
public_v6=2001:67c:21bc:8000::ff
peer_vlan=700
max_port=22

if [ "$1" 1= 22 ]; then
	max_port=$1
fi

s=0
p=4
for i in $(seq 1 $max_port); do
	let a=$s+2
	let v6=$p+2
	let left_peer=$i-1
	let left_peer_vlan=peer_vlan+i-1
	let right_peer=$i+1
	let right_peer_vlan=peer_vlan+i+1
	if (( $left_peer < 1 )); then
		left_peer=$max_port
	fi
	if (( $right_peer > $max_port )); then
		right_peer=1
		right_peer_vlan=$(( $peer_vlan + 1 ))
	fi
	if (( $i < 10 )); then
		as=0$i
	else
		as=$i
	fi
	echo "
----------------------------------------------
Switch port: $i
Your ASN:  655$as
Tom ASN:   65490
Jerry ASN: 65491
IX-1 ASN:  65492
IX-2 ASN:  65493
Your IPv4 prefix: ${public_v4}.$p/30
Your IPv6 prefix: ${public_v6}$as/64

VLAN to peer port $left_peer: $left_peer_vlan
VLAN to peer port $right_peer: $right_peer_vlan
VLAN to Tom   (Upstream1): $(($tom_vlan+$i))
VLAN to Jerry (Upstream2): $(($jerry_vlan+i))
VLAN to IX-1: $ix1_vlan
VLAN to IX-2: $ix2_vlan

IX-1
  IPv4: $ix1_ipv4
  IPv6: $ix1_ipv6

IX-2
  IPv4: $ix2_ipv4
  IPv6: $ix2_ipv6

IP settings for Tom:	${tom_v4}.$s/30
  peer: ${tom_v4}.$(($s+1))
  IPv4: ${tom_v4}.$a
  Mask: 255.255.255.252 ( /30 )
  peer: ${tom_v6}$(($v6-1))
  IPv6: ${tom_v6}$v6 /126

IP settings for Jerry:   ${jerry_v4}.$s/30
  peer: ${jerry_v4}.$(($s+1))
  IPv4: ${jerry_v4}.$a
  Mask: 255.255.255.252 ( /30 )
  peer: ${jerry_v6}$(($v6-1))
  IPv6: ${jerry_v6}$v6 /126

IP settings for IX-1:
  IPv4: ${ix1_v4}.$i
  Mask: 255.255.255.0 ( /24 )
  IPv6: ${ix1_v6}$i /64

IP settings for IX-2:
  IPv4: ${ix2_v4}.$i
  Mask: 255.255.255.0 ( /24 )
  IPv6: ${ix2_v6}$i /64
----------------------------------------------


"
	let p+=4
	let s+=4
done
