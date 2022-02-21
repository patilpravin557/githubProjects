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


# Duplicate 

Extract (unzip) new jar file with 7zip---from dev 

Open original jar file with 7 zip (do not extract) and drag and drop here the new updated files 

Copy new updated jar file in ts-app folder 

Update the build.batch file with new image tag 

Run the build.batch check the new iamge into nexus 

Scale down the deployment  

Update deplyment with new image tag 

Scale up deployment 

Test 

 

 

 

Jar file location: 

 

/opt/WebSphere/AppServer/profiles/default/installedApps/localhost/ts.ear/Foundation-Server.jar 
 
