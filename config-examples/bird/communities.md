
On the sending BIRD you can send communities by adding something like this to the output filter:

  if net ~ 77.104.187.0/24+ then bgp_community.add((myas, 10));

On the receiving BIRD you can match communities by adding 

  if (10, peeras) ~ bgp_community then return false;



