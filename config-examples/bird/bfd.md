
In order to enable BFD for any client, first you need to setup the BFD protocol. 
The important part is that if you have many interfaces you need one neighbor definition per interface.

  protocol bfd test_bfd {
        debug off;
        interface "*" {
                multiplier 3;
                interval 300ms;
        };
        neighbor 10.0.55.1 dev "eth0" local 10.0.55.2;
  }

After you have setup the BFD protocol, the only thing you need to add to your BGP peer configuration is "bfd;" to enable bfd for that peer:

  protocol bgp client1 from PEERS {
        neighbor 10.0.56.2 as 65501;
        source address 10.0.56.1;
		bfd;
  }

