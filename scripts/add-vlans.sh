#!/bin/bash
# This script is used to assign all vlans to their respective containers

# Add the individual vlans from clients
iface=10
max_port=22
if [ "$1" != 22 ]; then
    max_port=$1
fi
for i in $(seq -w 1 $max_port); do
        lxc config device add tom   eth$iface nic nictype=macvlan parent=eth1.4$i name=eth$iface
        lxc config device add jerry eth$iface nic nictype=macvlan parent=eth1.3$i name=eth$iface
        let iface++
done

# Add the VLANs for both Internet Exchanges
lxc config device add ix1 eth2 nic nictype=macvlan parent=eth1.500 name=eth2
lxc config device add ix2 eth2 nic nictype=macvlan parent=eth1.600 name=eth2
