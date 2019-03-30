Since there is considerable difference between the interfaces of Bird and Quagga.
Here are a few commands and their equivalents in both daemons.


On the left side are the Quagga commands. 
On the right side are the bird commands.


show ip route -- show route [table XXX]
show ip route bgp -- show route [table XXX] protocol <protocol_name> (show route proto ospf2 )
show ip route 1.2.0.0 longer- -- show route where net ~ 1.2.0.0/16
show ip bgp 1.2.0.0 -- show route where net ~ 1.2.0.0/16 all
show ip bgp sum -- show protocols
show ip bgp neighbors 1.2.3.4 -- show protocols all <protocol_name> (show protocols all ospf2)
show ip bgp neighbors 1.2.3.4 advertised-routes -- show route export <protocol_name>
clear ip bgp 1.2.3.4 -- reload <protocol_name> [in/out]
show ip route summary -- show route [table XXX] count
