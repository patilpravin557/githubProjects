# Utils

DEBUG SEGFAULT 

  

This will crash redis. Useful for circuit breaker testing  

  

CLIENT PAUSE <timeout>        -- Suspend all Redis clients for <timout> milliseconds. 

  

Pause all clients. simulates slowdowns 

  

DEBUG POPULATE <count> [prefix] [size] -- Create <count> string keys named key:<num>. If a prefix is specified is used instead of the 'key' prefix. 

  

Quick and easy way to fill up data 

  

It can also be done from command line: 

for i in `seq 1 3000`; do redis-cli -a admin "set" "key_{key1}_$i" `tr -dc A-Za-z0-9 </dev/urandom | head -c 1000`; done 

  

This: `tr -dc A-Za-z0-9 </dev/urandom | head -c 1000`  returns a random string 
