#!/bin/bash

tom_vlan=300
tom_v4=10.0.55
tom_v6=2001:7fc:21bc:8000::1:
jerry_vlan=400
jerry_v4=10.0.56
jerry_v6=2001:7fc:21bc:8001::2:
ix1_vlan=500
ix1_v4=10.0.57
ix1_v6=2001:7fc:21bc:8002::
ix1_ipv4=10.0.57.254
ix1_ipv6=2001:7fc:21bc:8002::fffe
ix2_vlan=600
ix2_v4=10.0.58
ix2_v6=2001:7fc:21bc:8003::
ix2_ipv4=10.0.58.254
ix2_ipv6=2001:7fc:21bc:8003::fffe
public_v4=151.216.4
public_v6=2001:7fc:21bc:81
peer_vlan=700
max_port=40

if [[ $1 -gt 22 ]]; then
	max_port=$1
fi

s=0
p=0
for i in $(seq 1 $max_port); do
	v6=$p
	let a=$s+2
	let ix=$i
	left_peer=$(printf "%2d" $(($i-1)))
	let left_peer_vlan=peer_vlan+i-1
	right_peer=$(printf "%2d" $(($i+1)))
	let right_peer_vlan=peer_vlan+i+1
	if (( $left_peer < 1 )); then
		left_peer=$(printf "%2d" $max_port)
	fi
	if [[ $right_peer > $max_port ]]; then
		right_peer=$(printf "%2d" 1)
		right_peer_vlan=$(( $peer_vlan + 1 ))
	fi
	if (( $i < 10 )); then
		as=0$i
	else
		as=$i
	fi
	#v6_start=$(printf "%04x" $(($v6+1)))
	v6_start=$(printf "%x" $(($v6+1)))
	v6_end=$(printf "%x" $(($v6+2)))
	let v6=$p+4
	v6_ix=$(printf "%x" $ix)
	echo "Generating client $i"
	echo "
----------------------------------------------
Switch port: $i
Your ASN:  655$as
Tom ASN:   65490
Jerry ASN: 65491
IX-1 ASN:  65492
IX-2 ASN:  65493
Your public IPv4 prefix: ${public_v4}.$p/30
Your public IPv6 prefix: ${public_v6}$as::/64

Router ID: ${tom_v4}.$a

VLAN to peer port $left_peer: $left_peer_vlan
VLAN to peer port $right_peer: $right_peer_vlan
VLAN to Tom   (Upstream1): $(($tom_vlan+$i))
VLAN to Jerry (Upstream2): $(($jerry_vlan+i))
VLAN to IX-1: $ix1_vlan
VLAN to IX-2: $ix2_vlan

IP settings for connection to Tom:    ${tom_v4}.$s/30  VLAN $(($tom_vlan+$i))
  Gateway:   ${tom_v4}.$(($s+1))
  Your IPv4: ${tom_v4}.$a
  Netmask:   255.255.255.252 ( /30 )
  Gateway:   ${tom_v6}$v6_start
  Your IPv6: ${tom_v6}$v6_end /126

IP settings for connection to Jerry:  ${jerry_v4}.$s/30  VLAN $(($jerry_vlan+$i))
  Gateway:   ${jerry_v4}.$(($s+1))
  Your IPv4: ${jerry_v4}.$a
  Netmask:   255.255.255.252 ( /30 )
  Gateway:   ${jerry_v6}$v6_start
  Your IPv6: ${jerry_v6}$v6_end /126

IP settings for connection to IX-1:         VLAN 500
  IX IPv4:   $ix1_ipv4
  Your IPv4: ${ix1_v4}.$ix
  Netmask:   255.255.255.0 ( /24 )
  IX IPv6:   $ix1_ipv6
  Your IPv6: ${ix1_v6}$v6_ix /64

IP settings for connection to IX-2:         VLAN 600
  IX IPv4:   $ix2_ipv4
  Your IPv4: ${ix2_v4}.$ix
  Netmask:   255.255.255.0 ( /24 )
  IX IPv6:   $ix2_ipv6
  Your IPv6: ${ix2_v6}$v6_ix /64
----------------------------------------------


" > client-$i.txt

	let p+=4
	let s+=4
done
