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
 
 
 ## javacore
 
 Kill –3 PID 

 

[root@demoqalivets-app-6f6d4bd7d8-l4kmn ts_demoqalivets-app-6f6d4bd7d8-l4kmn]# pwd 

/opt/WebSphere/AppServer/profiles/default/logs/container/ts_demoqalivets-app-6f6d4bd7d8-l4kmn 

 

[root@demoqalivets-app-6f6d4bd7d8-l4kmn ts_demoqalivets-app-6f6d4bd7d8-l4kmn]# ll 

total 136352 

drwxr-xr-x 2 root root      4096 Aug  9 14:14 ffdc 

-rw-r--r-- 1 root root 120587891 Aug 10 07:08 heapdump.20210810.070845.4075.0001.phd 

-rw-r--r-- 1 root root   5823160 Aug 10 07:08 javacore.20210810.070845.4075.0002.txt 
