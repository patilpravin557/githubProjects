# Kubectl top (CPU/Memory) 

https://github.com/kubernetes-sigs/metrics-server/issues/146 

https://github.com/helm/charts/tree/master/stable/metrics-server 

 

 

====================================================================== 

kubectl create ns metrics 

helm install metricsserver stable/metrics-server -n metrics 

 

Then edit deployment and add under - /metrics-server 

        - --kubelet-insecure-tls 

 

====================================================================== 

 

Eagle monitoring 

 

https://github.com/cloudworkz/kube-eagle 

https://github.com/cloudworkz/kube-eagle-helm-chart 

 

helm repo add kube-eagle https://raw.githubusercontent.com/cloudworkz/kube-eagle-helm-chart/master 

helm repo update 

helm install kube-eagle kube-eagle/kube-eagle -n metrics --set serviceMonitor.create=true 

( might need to kill prometheus to pick up new service monitor) 

 

 

 

Configure Grafana dashboard 

Import the dashboard: https://grafana.com/dashboards/9871 (Dashboard ID 9871) 

 

 

 

 

 

 

 

 
