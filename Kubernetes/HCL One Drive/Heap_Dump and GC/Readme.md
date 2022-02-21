## How to take heapdump and GC

Enter into pod 

Ps aux ---list pid 

 

Pid --> 3030  7.0  3.4 12590228 1132968 ?    SLl  09:54  10:30 /opt/WebSphere/AppServer/java/8.0/bin/java -Dosgi.install.area=/opt/WebSphere/AppServer -Dosg 

Kill –3  pid 

 

 

It will generate gc and heapdump file at below location 

TWAS 

Heap dump For TWAS 

/opt/WebSphere/AppServer/profiles/default/logs/container/ts_demoqalivets-app-649b8488f9-48ckb 

 

verbose GC log For TWAS 

/opt/WebSphere/AppServer/profiles/default/logs/server1 

 

kubectl cp commerce/<pod name>:/opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar ./Foundation-Server.jar 

 

Liberty 

 

Heap Dump for Liberty 

/opt/WebSphere/Liberty/usr/servers/default/logs/container/ESQuery_demoqalivequery-app-795ddc76b6-jhcrl 

 

Verbosegc for liberty 

/opt/WebSphere/Liberty/usr/servers/default 
