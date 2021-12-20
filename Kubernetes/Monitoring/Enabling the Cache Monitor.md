# Enabling the Cache Monitor 

Liberty 

 

Create an override file that enabled the feature 
 
<server> 
   <featureManager> 
       <feature>webCacheMonitor-1.0</feature> 
   </featureManager> 
</server> 
 

In your Dockerfile, copy the file as follows so the cache monitor is enaled 
 
COPY cachemonitor.xml /opt/WebSphere/Liberty/usr/servers/default/configDropins/overrides/cachemonitor.xml 
 

The Cache monitor can also be enabled for a running container 

 

Classic WAS 

 

TBD: The extended cache monitor needs to be installed with wsadmin.sh on the running server. Noureddine  is looking at creating a wsadmin script. We need to understand how this can be called when creating the image (Dockerfile) 
 
https://www.ibm.com/developerworks/websphere/downloads/cache_monitor.html 

 

 
