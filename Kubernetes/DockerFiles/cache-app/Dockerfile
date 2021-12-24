#https://comlnx94.prod.hclpnp.com/v2/federal_9.1.6.0/cache-app/tags/list
FROM comlnx94.prod.hclpnp.com/federal_9.1.6.0/cache-app:gmv2

#########################################################################
# Other configuration

#################
# JVM configuration
# Update HEAP Size
# RUN run set-heap-size 512 3072

#################
# Enable Json format/Log Level/console output of log types 
#COPY ./bootstrap.properties /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
#RUN echo "com.ibm.ws.logging.console.format=json" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
#RUN echo "com.ibm.ws.logging.console.log.level=info" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
#RUN echo "com.ibm.ws.logging.console.source=message,trace,accessLog,ffdc,audit" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties

#RUN echo "-verbose:gc" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options
#RUN echo "-Xverbosegclog:logs/verbosegc.%seq.log,5,51200" >> /opt/WebSphere/Liberty/usr/servers/default/jvm.options

#########################################################################
# Custom Logging
# COPY ./logging.xml /opt/WebSphere/Liberty/usr/servers/default/configDropins/overrides/logging.xml

################
# 1. Image build
# docker build -t performance/cache-app:gmv2 .

# 2. Image Tag
# docker tag performance/cache-app:gmv2 us.gcr.io/commerce-product/performance/cache-app:gmv2

# 3. Image Push
# docker push us.gcr.io/commerce-product/performance/cache-app:gmv2
