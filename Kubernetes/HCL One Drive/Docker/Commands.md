Docker Commands 


docker run -it -d --name prometheus -p 9090:9090 -v opt/docker/prometheus:etc/prometheus prom/prometheus  -config.file=etc/prometheus/prometheus.yml 

docker run -it -r --name prometheus -p 9090:9090 -v /etc/prometheus prom/prometheus  -config.file=/etc/prometheus/prometheus.yml 

docker run -it  --name exporter -p 9560:9560/tcp -v /etc/exporter adonato/query-exporter:latest -config.file=/etc/exporter/config.yaml 

  

docker run -p 9560:9560/tcp -v /etc/exporter/config.yaml:/config.yaml --rm -it adonato/query-exporter:latest -- /config.yaml 

  

docker run -p 9560:9560/tcp -v "$PWD/config.yaml:/config.yaml" --rm -it adonato/query-exporter:latest -- /config.yaml 

  

  

  

docker run -d -p 9090:9090 -v /etc/prometheus/prometheus.yml prom/prometheus -config.file=/etc/prometheus/prometheus.yml -storage.local.path=/prometheus -storage.local.memory-chunks=10000 

  

docker run -p 9560:9560/tcp -v /etc/exporter/config.yaml:/config.yaml --rm -it adonato/query-exporter:latest -- /config.yaml 

/etc/exporter 

  

docker run  --name db2  --privileged=true -d -p 50000:50000 -e LICENSE=accept -e DB2INST1_PASSWORD=db2inst1 -e DBNAME=test -v /home/ubuntu/DB2:/database ibmcom/db2 

  

docker run --name db2 -p 50000:50000 -e DB2INST1_PASSWORD=db2inst1 -e LICENSE=accept -d ibmcom/db2  sleep 2000000 

  

docker run -p 9560:9560/tcp -v "$PWD/config.yaml:/config.yaml" --rm -it adonato/query-exporter:latest -- /config.yaml 
