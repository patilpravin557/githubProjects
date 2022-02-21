Delete old jar from server 

/opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar 

 

Docker Image: ts-app 

Jar file: foundation-server.jar 
Class File Location : com\ibm\commerce\foundation\internal\server\services\dataaccess\queryservice\gen 

 

Put new jar into batch folder  

Tag the image 

Run the docker file 

Check 

 

Extract Jar 

 

[root@demoqalivets-app-6677bd4cc8-xqb9p jarfiletoextract]#  

jar xvf /opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar 

 
