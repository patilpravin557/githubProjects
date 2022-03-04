PS C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\stable\hcl-commerce> kubectl get pods -n default 

NAME                                            READY   STATUS    RESTARTS   AGE 

elastic-gke-logging-1-elasticsearch-0           1/1     Running   0          2d18h 

elastic-gke-logging-1-elasticsearch-1           1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-4gzhf          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-7ztgl          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-d64sv          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-gvbb4          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-nrvcz          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-p4gfp          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-v886f          1/1     Running   0          10h 

elastic-gke-logging-1-fluentd-es-x5cf9          1/1     Running   0          10h 

elastic-gke-logging-1-kibana-59947ffdfd-jgpzq   1/1     Running   3          2d18h 

PS C:\Users\pravinprakash.patil\Documents\gcp_commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\stable\hcl-commerce> kubectl port-forward svc/elastic-gke-logging-1-kibana-svc -n default 5601 

Forwarding from 127.0.0.1:5601 -> 5601 

Forwarding from [::1]:5601 -> 5601 
