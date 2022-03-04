 

kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 12000:9090 
 
kubectl port-forward -n monitoring service/prometheus-grafana 12001:80 

 

 

 

helm upgrade prometheus prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring --set prometheus.ingress.enabled=true --set grafana.ingress.enabled=true --set prometheus.ingress.hosts[0]=prometheus.pravin.perf-gcp-cluster.com 

  

  

  

helm install prometheus prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring 

  

kubectl delete crd alertmanagers.monitoring.coreos.com 

kubectl delete crd thanosrulers.monitoring.coreos.com 

kubectl delete crd servicemonitors.monitoring.coreos.com 

kubectl delete crd prometheusrules.monitoring.coreos.com 

kubectl delete crd prometheuses.monitoring.coreos.com 

kubectl delete crd probes.monitoring.coreos.com 

kubectl delete crd podmonitors.monitoring.coreos.com 

kubectl delete crd alertmanagerconfigs.monitoring.coreos.com 

  

  

helm search repo prometheus-community 

 
