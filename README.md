# idea
  To develop custom prometheus exporter for monitoring IBM db2 database which is hosted on Kubernetes cluster
  
# Problem Statement:

Prometheus is open source monitoring solution which can support kubernetes framework.

However, to monitor the db2 database no exporter written in prometheus .

Refer below prometheus officials details,

https://prometheus.io/docs/instrumenting/exporters/

Available Databases Exporters:

Aerospike exporter
ClickHouse exporter
Consul exporter (official)
Couchbase exporter
CouchDB exporter
Druid Exporter
ElasticSearch exporter
EventStore exporter
KDB+ exporter
Memcached exporter (official)
MongoDB exporter
MSSQL server exporter
MySQL router exporter
MySQL server exporter (official)
OpenTSDB Exporter
Oracle DB Exporter
PgBouncer exporter
PostgreSQL exporter
Presto exporter
ProxySQL exporter
RavenDB exporter
Redis exporter
RethinkDB exporter
SQL exporter
Tarantool metric library
Twemproxy

# Solution:

To write the custom prometheus db2 exporter using kubernetes objects and monitor the db2 database and view the metrics on prometheus console as well as on grafana dashboard. 
