@ECHO ON

REM Namespaces
REM --------------------
REM commerce
REM vault
REM elastic
REM zookeeper
REM redis
REM monitoring


REM
REM
REM Nodes
REM
REM

REM db2
CALL gcloud compute instances start perf-cluster2-ingest-db2-1 --zone us-east1-b


REM Kubernetes

CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=1 --zone us-east1-b --node-pool default-pool --project commerce-product --quiet
CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=3 --zone us-east1-b --node-pool elastic-pool --project commerce-product --quiet
CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=1 --zone us-east1-b --node-pool nifi-pool --project commerce-product --quiet


REM
REM
REM Prometheus/Grafana
REM
REM
kubectl scale statefulset alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring --replicas=1
kubectl scale statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring --replicas=1

kubectl scale deployment prometheus-grafana -n monitoring --replicas=1
kubectl scale deployment prometheus-kube-prometheus-operator -n monitoring --replicas=1
kubectl scale deployment prometheus-kube-state-metrics -n monitoring --replicas=1

REM
REM
REM Redis
REM
REM
kubectl scale statefulset redis-master -n redis --replicas=1

REM
REM
REM Zookeeper
REM
REM
kubectl scale statefulset zookeeper -n zookeeper --replicas=1

REM
REM
REM Elastic
REM
REM
kubectl scale statefulset elasticsearch-master -n elastic --replicas=3


REM
REM
REM Vault
REM
REM
kubectl scale deployment vault-consul -n vault --replicas=1


REM
REM
REM Commerce
REM
REM

REM kubectl scale deployment demoqalivecrs-app --replicas=1 -n commerce
REM kubectl scale deployment demoqalivedb --replicas=1 -n commerce
REM kubectl scale deployment demoqalivequery-app --replicas=1 -n commerce
REM kubectl scale deployment demoqalivestore-web --replicas=1 -n commerce
REM kubectl scale deployment demoqalivets-app --replicas=1 -n commerce
REM kubectl scale deployment demoqalivets-web --replicas=1 -n commerce

@ECHO Live environment not scaled up

kubectl scale deployment demoqanifi-app --replicas=1 -n commerce
kubectl scale deployment demoqaquery-app --replicas=1 -n commerce
kubectl scale deployment demoqaregistry-app --replicas=1 -n commerce
kubectl scale deployment demoqatooling-web --replicas=1 -n commerce
kubectl scale deployment demoqaingest-app --replicas=1 -n commerce

kubectl config set-context --current --namespace=commerce


