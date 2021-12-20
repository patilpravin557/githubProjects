## Elastic Search Exporter 

https://github.com/justwatchcom/elasticsearch_exporter 

https://github.com/justwatchcom/elasticsearch_exporter/blob/master/examples/grafana/dashboard.json 

https://grafana.com/grafana/dashboards/2322 

 

 

Install 

helm install es-exporter stable/elasticsearch-exporter -n es --set serviceMonitor.enabled=true --set serviceMonitor.namespace=es --set es.uri=http://elasticsearch-master-headless:9200 

helm delete es-exporter -n es 

 

Display: 
https://grafana.com/grafana/dashboards/2322 
