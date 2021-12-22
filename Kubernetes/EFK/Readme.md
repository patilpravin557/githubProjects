- [Elasticsearch Installation/Configuration](https://github01.hclpnp.com/commerce-dev/InstallGuides/tree/master/EFK#elasticsearch-installationconfiguration) (**E**)
- [Fluent Bit Installation](https://github01.hclpnp.com/commerce-dev/InstallGuides/blob/master/EFK/Readme.MD#fluentbit-installation) (**F**)
- [Kibana Installation](https://github01.hclpnp.com/commerce-dev/InstallGuides/tree/master/EFK#Kibana-Installation) (**K**)
- [Enabling json format logging in Liberty and TWAS](https://github01.hclpnp.com/commerce-dev/InstallGuides/tree/master/EFK#json-logging)

### Elasticsearch Installation/Configuration

#### To use local-storage for Elasticsearch nodes

* Create the namespace in which to install all three components
```
kubectl create namespace es
```
N.B. Use an alternative namespace to the Elasticsearch deployment used for Commerce search

* Create Filesystem paths on all target ES Nodes (nodes 1,2,3) and declare nodes in es-pv.yaml
   ex.
```   
mkdir -p /pv/es
```

* Create Node labels for identifiying desired Elastic Nodes
```
kubectl label node <node 1> elasticsearch=local-storage
kubectl label node <node 2> elasticsearch=local-storage
kubectl label node <node 3> elasticsearch=local-storage
```
label has been pre-defined in values.yaml
```
...
nodeSelector:
    elasticsearch=local-storage
...
```

N.B. To Remove a label (use -):
```
ex. [root@com-kube-master es]# kubectl label nodes comp-3751-1 elasticsearch-
node/comp-3751-1 labeled
```
#### Create the Persistent Volumes
* edit es.pv.yaml and update PV names and nodeAffinity values. ex. <node 1> and <nodeName 1>, etc.
```
kubectl -create es-pv.yaml -n es
```
#### Install Elasticsearch
```
helm repo add elastic https://helm.elastic.co
helm install elasticsearch elastic/elasticsearch -f values.yaml -n elastic
```

### Fluentbit Installation

```
helm install fluent-bit stable/fluent-bit --namespace es --set backend.type=es --set backend.es.host=elasticsearch-master.es.svc.cluster.local
```
### Kibana Installation
```
helm install kibana elastic/kibana --namespace es --set ingress.enabled=true --set ingress.hosts[0]=kibana.demoqalive.nonprod.hclpnp.com
```
### Json Logging
#### TWAS
```
#################
# Json Logging
COPY binary_logging.py /SETUP/ext-config/binary_logging.py
RUN cp /SETUP/bin/entrypoint.sh /SETUP/bin/entrypoint.sh.back
RUN cat /SETUP/bin/entrypoint.sh.back | sed 's/while \[ ! -f $traceFile \]; do sleep 0.1; done//' | sed 's/tail -F $traceFile --pid $SERVER_PID -n +0 \&/\/opt\/WebSphere\/AppServer\/bin\/logViewer.sh -monitor 1 -resumable -resume -format json \&/' > /SETUP/bin/entrypoint.sh
RUN echo "/profile/bin/wsadmin.sh -conntype None -f /SETUP/ext-config/binary_logging.py" > /SETUP/bin/custConfiguration.sh
RUN chmod u+x /SETUP/bin/entrypoint.sh
RUN chmod u+x /SETUP/bin/custConfiguration.sh
RUN mkdir -p /opt/WebSphere/AppServer/profiles/default/logs/server1/logdata
```

#### Liberty
```
#################
# Enable Json format & Log Level & console output of log types 
RUN echo "com.ibm.ws.logging.console.format=json" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
RUN echo "com.ibm.ws.logging.console.log.level=info" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
RUN echo "com.ibm.ws.logging.console.source=message,trace,accessLog,ffdc,audit" >> /opt/WebSphere/Liberty/usr/servers/default/bootstrap.properties
```

### Optionl: Modify Fluent Config Map to restrict log capture to commerce logs only

1. Edit the config map: kubectl edit cm fluent-bit-config -nes
2. Modify Path variable below (Path             /var/log/containers/\*.log\)

```# Please edit the object below. Lines beginning with a '#' will be ignored,
# and an empty file will abort the edit. If an error occurs while saving this file will be
# reopened with the relevant failures.
#
apiVersion: v1
data:
  fluent-bit-filter.conf: "[FILTER]\n    Name                kubernetes\n    Match
    \              kube.*\n    Kube_Tag_Prefix     kube.var.log.containers.\n    Kube_URL
    \           https://kubernetes.default.svc:443\n    Kube_CA_File        /var/run/secrets/kubernetes.io/serviceaccount/ca.crt\n
    \   Kube_Token_File     /var/run/secrets/kubernetes.io/serviceaccount/token\n
    \   Merge_Log           On\n    K8S-Logging.Parser  On\n    K8S-Logging.Exclude
    On\n    \n"
  fluent-bit-input.conf: "[INPUT]\n    Name             tail\n    Path             /var/log/containers/*commerce*.log\n
    \   Parser           docker\n    Tag              kube.*\n    Refresh_Interval
    5\n    Mem_Buf_Limit    5MB\n    Skip_Long_Lines  On\n    \n"
  fluent-bit-output.conf: "\n[OUTPUT]\n    Name  es\n    Match *\n    Host  elasticsearch-master.es.svc.cluster.local\n
    \   Port  9200\n    Logstash_Format On\n    Retry_Limit False\n    Type  flb_type\n
    \   Time_Key @timestamp\n    Replace_Dots On\n    Logstash_Prefix kubernetes_cluster\n\n\n\n
    \   \n"
```
