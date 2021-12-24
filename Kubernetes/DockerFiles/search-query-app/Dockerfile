FROM comlnx94.prod.hclpnp.com/9.1.8.0/search-query-app:v9-20211001-1104

#################
# ** SSLProvider Modifications
COPY ./java.security /opt/WebSphere/Liberty/java/8.0/jre/lib/security/java.security

#################
# ** SSL revert to 915 Java version: JAVA_HOME 

#copy to container path - /opt/WebSphere/Liberty/java/8.0
#COPY ./lib.java.zip /opt/WebSphere/Liberty/
#RUN unzip -o /opt/WebSphere/Liberty/lib.java.zip -d /opt/WebSphere/Liberty/

#################
# Configure Memory size for Native Mem.
RUN echo "-XX:MaxDirectMemorySize=256m" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options
#RUN echo "-Xdump:stack:events=allocation,filter=#300k" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options

#########################################################################
# Older Test configurations

#################
# Enable Json format/Log Level/console output of log types 
#https://www.ibm.com/docs/en/was-liberty/core?topic=liberty-logging-trace
#COPY ./bootstrap.properties /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties

#RUN echo "com.ibm.ws.logging.console.format=json" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
#RUN echo "com.ibm.ws.logging.console.log.level=info" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
#RUN echo "com.ibm.ws.logging.console.source=message,trace,accessLog,ffdc,audit" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties

#COPY ./jvm.options /opt/WebSphere/Liberty/usr/servers/default/jvm.options
#RUN echo "-verbose:gc" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options
#RUN echo "-Xverbosegclog:logs/verbosegc.%seq.log,5,51200" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options
#RUN sed -i "s/-Xdump:heap:events=user//g" /opt/WebSphere/Liberty/usr/servers/default/jvm.options

#########################################################################
# Custom Logging
# Modificationsto server.xml for accessLogging
#    <httpEndpoint host="*" httpPort="30900" httpsPort="30901" id="defaultHttpEndpoint">
#    <!--<accessLogging filepath="${server.output.dir}/logs/http_defaultEndpoint_access.log"
#        logFormat='%h %i %u %t "%r" %s %b %D' /> -->
#	</httpEndpoint>
COPY ./server.xml /opt/WebSphere/Liberty/usr/servers/default/server.xml

#Set Trace Specification details
COPY ./logging.xml /opt/WebSphere/Liberty/usr/servers/default/configDropins/overrides/logging.xml

#Configure Threaddump
COPY ./thread_monitor.yaml /SETUP/support/thread_monitor.yaml

#################
# JVM configuration
# Update HEAP Size
# RUN run set-heap-size 512 3072

##### Test Cache TTL of 300 (5 mins.) vs 172800 (48 hours)
#COPY ./cachespec.xml /opt/WebSphere/Liberty/usr/servers/default/apps/search-query.ear/search-query.war/WEB-INF/cachespec.xml 
#COPY ./wc-component.json /opt/WebSphere/Liberty/usr/servers/default/apps/search-query.ear/search-query.war/WEB-INF/classes/wc-component.json 

#########################################################################
# Debug with .esa patches/Configuration

#COPY ./hcl-cache-9.1.6.0-20210219.203418-25.esa /SETUP/hcl-cache/hcl-cache-1.0.esa
#RUN /opt/WebSphere/Liberty/bin/installUtility uninstall --noPrompts hcl-cache-1.0
#RUN /opt/WebSphere/Liberty/bin/installUtility install /SETUP/hcl-cache/hcl-cache-1.0.esa

#COPY ./cache_cfg.yaml /SETUP/hcl-cache/cache_cfg.yaml

################
# 1. Image build
# docker build -t performance/search-query-app:gmv2 .

# 2. Image Tag
# docker tag performance/search-query-app:gmv2 us.gcr.io/commerce-product/performance/search-query-app:gmv2

# 3. Image Push
# docker push us.gcr.io/commerce-product/performance/search-query-app:gmv2
