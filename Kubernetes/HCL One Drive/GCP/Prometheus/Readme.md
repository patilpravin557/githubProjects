[root@demoqalivets-app-6f7df487fb-shlbt /]# curl http://localhost:5280/monitor/metrics 

After installation of prometehus if commerce servicemonitor not showing in targets then do this  

 

[19:03] Andres Voldman 

  serviceMonitorNamespaceSelector: { }   serviceMonitorSelector: { }  

  

[19:03] Andres Voldman 

kubectl edit prometheus -n monitoring 

 

[19:05] Andres Voldman 

matchLabels: 
release: prometheus 
  

  

[19:05] Andres Voldman 

it's only configure sevicemonitors that have the prometheus label 

  

[19:05] Andres Voldman 

so remove those two lines and replace with { } on the line above 

  

[19:05] Andres Voldman 

basically you remove all the filters 

 

 

kubectl port-forward -n monitoring service/prometheus-grafana 12001:80 

 

kubectl port-forward -n monitoring service/prometheus-kube-prometheus-prometheus 12000:9090 

 

 

 

helm upgrade prometheus prometheus-community/kube-prometheus-stack -f values.yaml -n monitoring --set prometheus.ingress.enabled=true --set grafana.ingress.enabled=true --set prometheus.ingress.hosts[0]=prometheus.pravin.perf-gcp-cluster.com 

  

PS C:\Users\pravinprakash.patil\AppData\Local\Google\Cloud SDK> kubectl exec -it prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring -- /bin/sh                                                       Defaulting container name to prometheus. 

Use 'kubectl describe pod/prometheus-prometheus-kube-prometheus-prometheus-0 -n monitoring' to see all of the containers in this pod. 

/prometheus $ du -k /prometheus 

  

  

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
