on host  (only needs to be done once) 
sudo bash -c 'echo "core" > /proc/sys/kernel/core_pattern' 
 
Check it contains "core" 
cat /proc/sys/kernel/core_pattern 
 

 

 

[10/1 7:41 PM] Andres Voldman 

output looks like this 

[root@demoqalivequery-app-5485f6556d-dqhcg /]# /opt/WebSphere/Liberty/bin/./server dump default --include=system 
Dumping server default. 
Server default dump complete in /opt/WebSphere/Liberty/usr/servers/default/default.dump-20.10.01_13.32.33.zip. 
 
  

 

/opt/WebSphere/Liberty/bin/server dump default --include=system,heap 

 

 

./server javadump default --include=system 
./server javadump default --include=thread 
./server javadump default --include=heap 
 
