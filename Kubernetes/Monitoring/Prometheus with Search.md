# Prometheus with Search 

Enabling Search and CRS metrics using Liberty microprofile 

 

metrics.xml 
 

<server> 

   <featureManager> 

     <feature>mpMetrics-1.1</feature> 

     <feature>monitor-1.0</feature> 

   </featureManager> 

   <mpMetrics authentication="false"/> 

</server> 

 

 

Dockerfile 

 

RUN /opt/WebSphere/Liberty/bin/installUtility install mpmetrics-1.1 
COPY metrics.xml /opt/WebSphere/Liberty/usr/servers/default/configDropins/overrides/metrics.xml 

 

CRS Only: 
mpmMetrics enabled JSP 2.3. This is incompatible with the CRS server.xml which enabled JSP2.2. 
Add the following sed command to the Docker file to replace JSP 2.2 with 2.3 in server.xml: 
 
RUN sed -i -e 's/jsp-2.2/jsp-2.3/g' /opt/WebSphere/Liberty/usr/servers/default/server.xml 

  

 

Note: Metrics (/metrics) are enabled on the same port as the application. Although metrics are not generally sensitive to require user and password, they should NOT be exposed to end users. Ensure that the ingress definition is not configured to "/", e.g. for Store it can be "/shop" so metrics are not inadvertently  made available externally 

 

 

 

 
