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
REM Commerce
REM
REM
kubectl scale deployment demoqaingest-app --replicas=0 -n commerce
kubectl scale deployment demoqalivecrs-app --replicas=0 -n commerce
kubectl scale deployment demoqalivedb --replicas=0 -n commerce
kubectl scale deployment demoqalivequery-app --replicas=0 -n commerce
kubectl scale deployment demoqalivestore-web --replicas=0 -n commerce
kubectl scale deployment demoqalivets-app --replicas=0 -n commerce
kubectl scale deployment demoqalivets-web --replicas=0 -n commerce

kubectl scale deployment demoqanifi-app --replicas=0 -n commerce
kubectl scale deployment demoqaquery-app --replicas=0 -n commerce
kubectl scale deployment demoqaregistry-app --replicas=0 -n commerce
kubectl scale deployment demoqatooling-web --replicas=0 -n commerce

REM
REM
REM Vault
REM
REM
kubectl scale deployment vault-consul -n vault --replicas=0 

REM
REM
REM Elastic
REM
REM
kubectl scale statefulset elasticsearch-master -n elastic --replicas=0

REM
REM
REM Zookeeper
REM
REM
kubectl scale statefulset zookeeper -n zookeeper --replicas=0

REM
REM
REM Redis
REM
REM
kubectl scale statefulset redis-master -n redis --replicas=0

REM
REM
REM Prometheus/Grafana
REM
REM
kubectl scale statefulset alertmanager-prometheus-kube-prometheus-alertmanager -n monitoring --replicas=0
kubectl scale statefulset prometheus-prometheus-kube-prometheus-prometheus -n monitoring --replicas=0

kubectl scale deployment prometheus-grafana -n monitoring --replicas=0
kubectl scale deployment prometheus-kube-prometheus-operator -n monitoring --replicas=0
kubectl scale deployment prometheus-kube-state-metrics -n monitoring --replicas=0


REM
REM
REM Nodes
REM
REM

REM Kubernetes

CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=0 --zone us-east1-b --node-pool default-pool --project commerce-product --quiet
CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=0 --zone us-east1-b --node-pool elastic-pool --project commerce-product --quiet
CALL gcloud container clusters resize perf-cluster2-ingest --num-nodes=0 --zone us-east1-b --node-pool nifi-pool --project commerce-product --quiet

REM DB2
CALL gcloud compute instances stop perf-cluster2-ingest-db2-1 --zone us-east1-b



