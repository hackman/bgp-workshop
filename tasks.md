
1. Setup DHCP client on your port and connect to the Internet
2. Setup the VLANs to the upstream providers (Tom & Jerry)
VLAN 3xx
VLAN 4xx
3. Setup the VLAN to IX-1 - vlan 500
4. Setup the VLAN to IX-2 - vlan 600
5. Setup the BGP sessions with Tom (VLAN 3xx) & Jerry (VLAN 4xx)
6. Setup the BGP sessions with IX-1(VLAN 500) & IX-2 (VLAN 600)
7. Start announcing some RFC1918 prefix via one of the IX
8. Setup the VLANs to your neighboors 
9. Choose an IP range between you and your neighboor
10. Setup BGP sessions with your neighboors

