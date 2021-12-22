#FROM comlnx94.prod.hclpnp.com/9.1.2.0/search-registry-app:v9-latest
FROM comlnx94.prod.hclpnp.com/9.1.1.0/search-registry-app:v9-latest

#########################################################################
# Other configuration

#################
# JVM configuration
# Update HEAP Size
# RUN run set-heap-size 512 3072

################
# Logging
#COPY binary_logging.py /SETUP/ext-config/binary_logging.py
#RUN cp /SETUP/bin/entrypoint.sh /SETUP/bin/entrypoint.sh.back
#RUN cat /SETUP/bin/entrypoint.sh.back | sed 's/while \[ ! -f $traceFile \]; do sleep 0.1; done//' | sed 's/tail -F $traceFile --pid $SERVER_PID -n +0 \&/\/opt\/WebSphere\/AppServer\/bin\/logViewer.sh -monitor 1 -resumable -resume -format json \&/' > /SETUP/bin/entrypoint.sh
#RUN echo "/profile/bin/wsadmin.sh -conntype None -f /SETUP/ext-config/binary_logging.py" > /SETUP/bin/custConfiguration.sh
#RUN chmod u+x /SETUP/bin/entrypoint.sh
#RUN chmod u+x /SETUP/bin/custConfiguration.sh
#RUN mkdir -p /opt/WebSphere/AppServer/profiles/default/logs/server1/logdata

