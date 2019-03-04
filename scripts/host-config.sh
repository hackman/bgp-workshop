#!/bin/bash

# VLAN 300 for upstream networking and connectivity between routers
# VLAN 500 for IX-1
# VLAN 600 for IX-2
vlans='300 500 600'
out_dev=eth0
max_port=40

if [[ $# -ne 1 ]] && [[ $# -ne 2 ]]; then
        echo "Usage: $0 setup|remove [max ports]"
        exit
fi

if [[ -n $2 ]]; then
    max_port=$2
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

function add_vlans_to_containers {
	for i in $(seq -w 1 $max_port); do
		lxc config device add tom   eth0.3$i nic nictype=macvlan parent=${out_dev}.3$i name=eth0.3$i
	done
	a=1
	for i in $(seq -w 1 $max_port); do
		lxc config device add jerry eth0.4$i nic nictype=macvlan parent=${out_dev}.4$i name=eth0.4$i
	done

	# Add the VLANs for both Internet Exchanges
	lxc config device add ix1 eth2 nic nictype=macvlan parent=${out_dev}.500 name=eth2
	lxc config device add ix2 eth2 nic nictype=macvlan parent=${out_dev}.600 name=eth2
}

function del_vlans_to_containers {
	for i in $(seq -w 1 $max_port); do
		lxc config device remove tom   eth0.3$i
		lxc config device remove jerry eth0.4$i
	done

	# Add the VLANs for both Internet Exchanges
	lxc config device remove ix1 eth2
	lxc config device remove ix2 eth2
}

function remove_interfaces() {
	# VLAN 300 for upstream networking and connectivity between routers
	# VLAN 500 for IX-1
	# VLAN 600 for IX-2
	for i in $vlans; do
        ip l s down dev ${out_dev}.$i
		ip l d ${out_dev}.$i
	done
	for i in $(seq -w 1 $max_port); do
		# 3xx VLANs to Jerry
        ip l s down dev ${out_dev}.3$i
		ip l d ${out_dev}.3$i
		# 4xx VLANs to Tom
        ip l s down dev ${out_dev}.4$i
		ip l d ${out_dev}.4$i
	done

	del_vlans_to_containers

	tom_eth0=$(lxc info tom|awk '/eth0.*inet\s/{print $4}')
	jerry_eth0=$(lxc info jerry|awk '/eth0.*inet\s/{print $4}')

	# Add vlan 300 to this bridge and setup its ipv4 configuration
	brctl delif v300 ${out_dev}.300
	brctl delif v300 $tom_eth0
	brctl delif v300 $jerry_eth0
	ip l s down v300
	brctl delbr v300
}

function setup_interfaces() {
	# VLAN 300 for upstream networking and connectivity between routers
	# VLAN 500 for IX-1
	# VLAN 600 for IX-2
	for i in $vlans; do
		#vconfig add $out_dev $i
		ip l a link $out_dev name ${out_dev}.$i type vlan id $i
        ip l s up dev ${out_dev}.$i
	done
	for i in $(seq -w 1 $max_port); do
		# 3xx VLANs to Jerry
		ip l a link $out_dev name ${out_dev}.3$i type vlan id 3$i
        #vconfig add $out_dev 3$i
        ip l s up dev ${out_dev}.3$i
	done
	for i in $(seq -w 1 $max_port); do
		# 4xx VLANs to Tom
        #vconfig add $out_dev 4$i
		ip l a link $out_dev name ${out_dev}.4$i type vlan id 4$i
        ip l s up dev ${out_dev}.4$i
	done

	add_vlans_to_containers

	tom_eth0=$(lxc info tom|awk '/eth0.*inet\s/{print $4}')
	jerry_eth0=$(lxc info jerry|awk '/eth0.*inet\s/{print $4}')

	# lxdbr0 is the default LXD bridge
#	brclt addbr br0
	# v300 is the bridge that connects all routers to the upstream network
	brctl addbr v300
	# Add vlan 300 to this bridge and setup its ipv4 configuration
	brctl addif v300 ${out_dev}.300
	brctl addif v300 $tom_eth0
	brctl addif v300 $jerry_eth0
	ip l s up v300
#	ip a a 172.31.190.14/24 dev v300
#	ip r r 0/0 via 172.31.190.1
	ip a a 10.2.2.5/24 dev v300
	ip r a 0/0 via 10.2.2.1
	# finally, make sure that this router, routes :)
	sysctl net.ipv4.ip_forward=1
	# clear the firewall
	iptables -P INPUT ACCEPT
	iptables -P OUTPUT ACCEPT
	iptables -P FORWARD ACCEPT
	iptables -F
}


#mount_cgroups
if [[ $1 == 'setup' ]]; then
	setup_interfaces
else
	remove_interfaces
fi
