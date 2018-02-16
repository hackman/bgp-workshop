#!/bin/bash

out_dev=eth0
max_port=21
vlans='2 300 500 600'

# 2   - DHCP internet VLAN
# 300 - 
# 500 - IX1 VLAN
# 600 - IX2 VLAN

for i in $vlans; do
	ip l a link $out_dev name ${out_dev}.$i type vlan id $i
	ip l s up ${out_dev}.$i
done

for i in $(seq -w 1 $max_port); do
#	vconfig add $out_dev 3$i
#	vconfig add $out_dev 4$i
#	vconfig add $out_dev 7$i
	ip l a link $out_dev name ${out_dev}.3$i type vlan id 3$i
	ip l a link $out_dev name ${out_dev}.4$i type vlan id 4$i
	ip l a link $out_dev name ${out_dev}.7$i type vlan id 7$i
	ip l s up ${out_dev}.3$i
	ip l s up ${out_dev}.4$i
	ip l s up ${out_dev}.7$i
done

brctl addbr lxdbr0
