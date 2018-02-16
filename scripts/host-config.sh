#!/bin/bash

max_port=22
if [ "$1" != 22 ]; then
    max_port=$1
fi

function mount_cgroups() {
	cgroups='cpu cpuset cpuacct memory devices pids net_prio freezer blkio'

	if ! mount|grep -q 'fs\/cgroup '; then
        mount -t tmpfs cgroup_root /sys/fs/cgroup
	fi
	for i in $cgroups; do
        if [ ! -d /sys/fs/cgroup/$i ]; then
                mkdir /sys/fs/cgroup/$i
        fi
        if ! mount|grep -q "cgroup/$i "; then
                echo "Mounting cgroup $i"
                mount -t cgroup -o$i $i /sys/fs/cgroup/$i
        fi
	done
}

function setup_interfaces() {
	out_dev=eth1
	vlans='300 500 600'
	# VLAN 300 for upstream networking and connectivity between routers
	# VLAN 500 for IX-1
	# VLAN 600 for IX-2
	for i in $vlans; do
        vconfig add $out_dev $i
        ip l s up dev ${out_dev}.$i
	done
	for i in $(seq -w 1 $max_port); do
		# 3xx VLANs to Jerry
        vconfig add $out_dev 3$i
        ip l s up dev ${out_dev}.3$i
		# 4xx VLANs to Tom
        vconfig add $out_dev 4$i
        ip l s up dev ${out_dev}.4$i
	done

	# lxdbr0 is the default LXD bridge
	brclt addbr lxdbr0
	# v300 is the bridge that connects all routers to the upstream network
	brctl addbr v300
	# Add vlan 300 to this bridge and setup its ipv4 configuration
	brctl addif v300 eth1.300
	ip l s up v300
	ip a a 172.31.190.14/24 dev v300
	ip r r 0/0 via 172.31.190.1
	# finally, make sure that this router, routes :)
	sysctl net.ipv4.ip_forward=1
}


mount_cgroups
setup_interfaces
