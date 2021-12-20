# Redis Docker

 

docker run -it --name redis -e ALLOW_EMPTY_PASSWORD=yes -p 6379:6379 bitnami/redis:latest /run.sh --maxmemory 1000mb --maxmemory-policy volatile-lru --appendonly no --save "" 

 helm repo add bitnami https://charts.bitnami.com/bitnami 

helm install  redis bitnami/redis --namespace redis --set cluster.enabled=false --set master.persistence.enabled=false --set usePassword=false  --set master.disableCommands="" --set metrics.enabled=true --set metrics.serviceMonitor.enabled=true --set metrics.serviceMonitor.namespace=redis 
