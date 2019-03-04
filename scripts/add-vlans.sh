#!/bin/bash
# This script is used to assign all vlans to their respective containers

# Add the individual vlans from clients
max_port=40
out_dev=eth0
if [[ -n $1 ]]; then
    max_port=$1
fi
for i in $(seq -w 1 $max_port); do
	lxc config device add tom   eth0.3$i nic nictype=macvlan parent=${out_dev}.3$i name=eth0.3$i
	lxc config device add jerry eth0.4$i nic nictype=macvlan parent=${out_dev}.4$i name=eth0.4$i
done

# Add the VLANs for both Internet Exchanges
lxc config device add ix1 eth2 nic nictype=macvlan parent=${out_dev}.500 name=eth2
lxc config device add ix2 eth2 nic nictype=macvlan parent=${out_dev}.600 name=eth2
