#!/bin/bash

# Version 2.1
#
# Usage:
# ---------------------------------------------------- 
#
#  Foreground:
#   ./kube_commerce_install.sh  2>&1 | tee install.log
#
#  Background: (can close terminal)
#    nohup ./kube_commerce_install.sh &> install.log &
#
# ----------------------------------------------------
# 
# 20201203 - Noureddine - Commented these lines if [ "$wn" = "$MASTER_NODE" ]; then continue fi so user would run ssh-copy-id on all nodes even master
# 20201203 - Noureddine - Changed a call to python3 to python at the end of the script
# 20201209 - Andres     - When Auth and Live are used, do push-to-live
#
# helm delete -n elastic elasticsearch
# helm delete -n elastic kibana
# helm delete -n zookeeper zookeeper
# helm delete -n redis redis
# helm delete -n vault vault
# helm delete -n commerce demo-qa-share
# helm delete -n commerce demo-qa-live
#

CLUSTER_SIZE=`kubectl get nodes --no-headers=true | wc -l`
MASTER_IP=`kubectl get nodes -o jsonpath={.items[*].status.addresses[?\(@.type==\"InternalIP\"\)].address} -l 'node-role.kubernetes.io/master'`
MASTER_NODE=`kubectl get nodes -o jsonpath={.items[*].metadata.name} -l 'node-role.kubernetes.io/master'`
CLUSTER_NODE_NAMES=`kubectl get nodes -o jsonpath={.items[*].metadata.name}`

# -------------------------------------------------------------------------------------------------------
#
#
# Configurations
#
#
# -------------------------------------------------------------------------------------------------------

# *_INSTALL values:
#  - no          Never install
#  - yes         Always install (cleans previous install if existing)
#  - if_missing  Install only if not installed previously
#  - cleanup     Only removes existing install

#
# Common
# ----------------------------------
DOMAIN=.andres.svt.hcl.com

#
# Nginx Configurations
# ----------------------------------
NGINX_INSTALL=if_missing

#
# Prometheus Operator Configurations
# ----------------------------------
PO_INSTALL=if_missing
# If not set, the master is used
PO_NODE=

GRAFANA_INTERNAL_REPOSITORY=http://10.190.66.196:8089

# /etc/httpd/conf/httpd.conf 
# /var/www/html/grafana/9.1.3/hcl-cache
# $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.3/hcl-cache/local-cache-details.json

# Listen 8089

# systemctl start httpd.service
# systemctl status httpd.service

#
# ZooKeeper
# ----------------------------------
ZK_INSTALL=if_missing
# If not set, the master is used
ZK_NODE=

#
# Elastic
# ----------------------------------
ES_INSTALL=if_missing
# Number of ES nodes
ES_NUM_NODES=3
# Optionally set the names of the nodes to use for ES
ES_CLUSTER_NODES=

#
# Kibana
# ----------------------------------
KIBANA_INSTALL=if_missing

#
# Redis
# ----------------------------------
REDIS_INSTALL=if_missing
REDIS_CLUSTER=false
#REDIS_PASSWORD=passw0rd
#REDIS_PASSWORD_ENCRYPT=yhy8xMB8uAH5XlrE2hn9HmhidwbcvgOjG+u+Plxo7vc=

#
# Vault
# ----------------------------------
VAULT_INSTALL=if_missing

#
# Commerce
# ----------------------------------
# searchEngine: [solr|elastic]
# Only elastic is supported by this version of the script
COMMERCE_SEARCH_ENGINE=elastic


COMMERCE_AUTH_INSTALL=if_missing
COMMERCE_SHARE_INSTALL=if_missing
COMMERCE_LIVE_INSTALL=if_missing

# Reindex will run even if share is not reinstalled
COMMERCE_FORCE_REINDEX=true


# set if using remote db
#COMMERCE_DB_IP=10.190.66.103
COMMERCE_DB_AUTH_IP=
COMMERCE_DB_LIVE_IP=

# 11    Emerald
COMMERCE_STORE_ID=11
COMMERCE_IMAGE_PATH=9.1.4.0

# https://comlnx94.prod.hclpnp.com/v2/9.1.3.0/tooling-web-app/tags/list

COMMERCE_IMAGE_TS_DB=${COMMERCE_IMAGE_PATH}/ts-db:v9-latest
COMMERCE_IMAGE_TOOLING_WEB=${COMMERCE_IMAGE_PATH}/tooling-web:v9-latest
COMMERCE_IMAGE_STORE_WEB=${COMMERCE_IMAGE_PATH}/store-web:v9-latest
COMMERCE_IMAGE_TS_WEB=${COMMERCE_IMAGE_PATH}/ts-web:v9-latest

COMMERCE_IMAGE_CRS=${COMMERCE_IMAGE_PATH}/crs-app:v9-latest
COMMERCE_IMAGE_SEARCH=${COMMERCE_IMAGE_PATH}/search-app:v9-latest

COMMERCE_IMAGE_INGEST=${COMMERCE_IMAGE_PATH}/search-ingest-app:v9-latest
COMMERCE_IMAGE_QUERY=${COMMERCE_IMAGE_PATH}/search-query-app:v9-latest
COMMERCE_IMAGE_TS=${COMMERCE_IMAGE_PATH}/ts-app:v9-latest
COMMERCE_IMAGE_NIFI=${COMMERCE_IMAGE_PATH}/search-nifi-app:v9-latest
COMMERCE_IMAGE_QUERY=${COMMERCE_IMAGE_PATH}/search-query-app:v9-latest
COMMERCE_IMAGE_REGISTRY=${COMMERCE_IMAGE_PATH}/search-registry-app:v9-latest
COMMERCE_IMAGE_XC=${COMMERCE_IMAGE_PATH}/xc-app:v9-latest
COMMERCE_IMAGE_SUPPORTC=${COMMERCE_IMAGE_PATH}/supportcontainer:v9-latest

COMMERCE_IMAGE_CACHE=${COMMERCE_IMAGE_PATH}/cache-app:v9-latest


COMMERCE_TENANT=demo
COMMERCE_ENV_NAME=qa

COMMERCE_NIFI_NODE=

# planned improvement: currently these values must be set
# support empty values
COMMERCE_NIFI_REQUEST_CPU="4"
COMMERCE_NIFI_LIMIT_CPU="10"
COMMERCE_NIFI_REQUEST_MEMORY="7168"

#COMMERCE_AUTH_NIFI_TUNING=nifi_tuning.json
#COMMERCE_LIVE_NIFI_TUNING=nifi_tuning.json

COMMERCE_INGEST_DASHBOARD_UID=hcl_nifi_performance

# https://github02.hclpnp.com/commerce-dev/commerce-helmchart
# https://github02.hclpnp.com/commerce-dev/commerce-helmchart/blob/master/test/ivt/commerce_values/ivt-GMV-9.1.2-ESdb2.yaml

COMMERCE_CHARTS='http://comlnx94.prod.hclpnp.com:8081/nexus/service/local/artifact/maven/redirect?r=v9_snapshots&g=com.hcl.commerce.deployment&a=commerce-helmchart&v=1.0-SNAPSHOT&p=zip'

#
# Disable ES configs if Solr is used...
#
if [ "$COMMERCE_SEARCH_ENGINE" != "elastic" ]; then    
  log "Only Elastic is supported"
  exit 1
fi


# -------------------------------------------------------------------------------------------------------
#
#
# Validation
#
#
# -------------------------------------------------------------------------------------------------------
function log {
  echo "** [`date`] $@"
}

log "Number of nodes in cluster: $CLUSTER_SIZE"

if [ $CLUSTER_SIZE -lt 1 ]
then
  log "ERROR: Unable to determine cluster size"
  exit 1
fi


#log "Ensure script runs from $MASTER_NODE"
ifconfig | grep -q $MASTER_IP
if [ $? -ne 0 ]; then    
  log "ERROR: Script must run from master node ($MASTER_IP)"
  exit 1
fi

log "Validating worker node configurations"

SHOW_SSH_SETUP=0

for wn in $CLUSTER_NODE_NAMES
do
  if [ "$wn" = "$MASTER_NODE" ]; then
    continue
  fi
  ssh root@$wn -o PasswordAuthentication=no 'test 1'
  if [ $? -ne 0 ]; then    
    log "ERROR: Unable to ssh to worker node ($wn) without password"
    SHOW_SSH_SETUP=1
    break
  fi
done

if [ $SHOW_SSH_SETUP -eq 1 ]
then

  log "To configure certification authentication, run "
  log "   ssh-keygen on master node and copy the certificates"
  log "   to all worker nodes:"
  log "    ssh-keygen"
  for wn in $CLUSTER_NODE_NAMES
  do
    #if [ "$wn" = "$MASTER_NODE" ]; then
    #  continue
    #fi
    log "    ssh-copy-id -i ~/.ssh/id_rsa.pub "`kubectl get node $wn -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`
  done
  
  exit 1
fi

if [ -z "${DOMAIN}" ]; then
  log "ERROR: Domain not set"
  exit 1
fi

#
# Validate system clocks
# 
for wn in $CLUSTER_NODE_NAMES
do
  log "System Clock for node $wn: `ssh root@$wn -o PasswordAuthentication=no date`"
done

# -------------------------------------------------------------------------------------------------------
#
#
# Helm
#
#
# -------------------------------------------------------------------------------------------------------
helm 2>&1 > /dev/null
if [ $? -ne 0 ]; then

  mkdir helm_install 2> /dev/null
  cd helm_install
  curl -o helm.tar.gz "https://get.helm.sh/helm-v3.4.0-rc.1-linux-amd64.tar.gz"
  tar -xvzf helm.tar.gz
  mv linux-amd64/helm /usr/local/bin/helm
  helm version
  cd - >/dev/null

else
  log "Helm is installed. Skipping...."
fi

# ------------------------------------------------------------------------
#
# Helm Local Repository Update
#
# ------------------------------------------------------------------------
log "Starting install process ($$)"
log "Existing Releases:"
helm list -A

log "Updating Helm Repositories"

helm version
helm repo add stable https://kubernetes-charts.storage.googleapis.com/
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx 
helm repo add elastic https://helm.elastic.co
helm repo update

# ------------------------------------------------------------------------
#
# Commerce Helm Chart Download 
#
# ------------------------------------------------------------------------
if [ -n "$COMMERCE_CHARTS" ]; then
  log "Downloading Commerce Helm Charts"
  curl -L $COMMERCE_CHARTS -o commerce_charts.zip
  rm -rf commerce-helmchart-master/*
  unzip -q commerce_charts.zip -d commerce-helmchart-master
else
  log "Location of Commerce Helm Charts not set: Not downloading"
fi

# ------------------------------------------------------------------------
#
# Utils
#
# ------------------------------------------------------------------------
function add_host_entry {

  domain=$1
  host_entry="$MASTER_IP ${domain}"
      
  grep -q ${domain} /etc/hosts
  if [ $? -ne 0 ]; then
    sudo echo $host_entry >> /etc/hosts
  fi
}

function wait_for_ready {

  namespace=$1
  application=$2
  
  keep_waiting=1
  loop_num=0
  
  log "Waiting for $application to start...."
  
  # 1 1/2 hour
  while [ $keep_waiting -eq 1 ] && [ $loop_num -lt 270 ]
  do
  
    kubectl -n $namespace get pods -o "custom-columns=ready:status.containerStatuses[*].ready" | grep -qE "none|false"
    if [ $? -ne 0 ]; then
      keep_waiting=0
    else
      sleep 20
      echo -n "."
    fi

    let loop_num=$loop_num+1
  done
  
  echo ""
  
  return $keep_waiting
}

function ingest_log_check {

  message_in_log=$1
  max_loops=$2

  ingest_pod=`kubectl get pod -n commerce -l component=${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app -o jsonpath="{.items[0].metadata.name}"`
    
  log "Waiting for message ($message_in_log) in Ingest pod: $INGEST_POD..."
    
  ingest_not_ready=1
  ingest_loop_num=0
    
  # 90=30 mins
  while [ $ingest_not_ready -eq 1 ] && [ $ingest_loop_num -lt $max_loops ]
  do
    kubectl logs -n commerce $ingest_pod | grep -q "$message_in_log"
    if [ $? -eq 0 ]; then
      ingest_not_ready=0
    else
      sleep 20
      echo -n "."
    fi

    let ingest_loop_num=$ingest_loop_num+1
  done
  
  echo ""
  
  return $ingest_not_ready
}

# -------------------------------------------------------------------------------------------------------
#
#
# Kubernetes Configuration
#
#
# -------------------------------------------------------------------------------------------------------
kubectl taint node $MASTER_NODE node-role.kubernetes.io/master:NoSchedule- 2> /dev/null

kubectl config set-context --current --namespace=commerce

cat <<EOF | kubectl apply -f -
apiVersion: rbac.authorization.k8s.io/v1beta1
kind: ClusterRoleBinding
metadata:
  name: commerce-rbac
subjects:
  - kind: ServiceAccount
    name: default
    namespace: commerce
roleRef:
  kind: ClusterRole
  name: cluster-admin
  apiGroup: rbac.authorization.k8s.io
EOF


# -------------------------------------------------------------------------------------------------------
#
#
# Prometheus Operator (includes Grafana)  
#
#
# -------------------------------------------------------------------------------------------------------
PO_STATUS=`helm status prometheus -n monitoring 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$PO_STATUS" = "deployed" ]
then
  log "Prometheus Operator release is pre-installed"
else
  log "Prometheus Operator release is not installed"
fi

if [ -z "$PO_NODE" ]; then
  PO_NODE=$MASTER_NODE
fi
  
if [ "$PO_INSTALL" = "cleanup" ] || [ "$PO_INSTALL" = "yes" ] || ( [ "$PO_INSTALL" = "if_missing" ] && [ "$PO_STATUS" != "deployed" ] )
then

  #
  # Prometheus Operator - Clean up...
  #
  # ----------------------------------------------------------------------------
  
  helm delete prometheus -n monitoring 2> /dev/null

  PROMETHEUS_PVC=`kubectl get pvc -n monitoring -l app=prometheus -o jsonpath="{.items[0].metadata.name}" 2> /dev/null`
  GRAFANA_PVC=`kubectl get pvc -n monitoring -l app.kubernetes.io/name=grafana -o jsonpath="{.items[0].metadata.name}" 2> /dev/null`
  
  if [ -n "$GRAFANA_PVC" ]; then
    kubectl patch pvc -n monitoring $GRAFANA_PVC -p '{"metadata":{"finalizers": []}}' --type=merge 2> /dev/null
    kubectl delete pvc -n monitoring $GRAFANA_PVC 2> /dev/null
  fi
  
  if [ -n "$PROMETHEUS_PVC" ]; then
    kubectl patch pvc -n monitoring $PROMETHEUS_PVC -p '{"metadata":{"finalizers": []}}' --type=merge 2> /dev/null
    kubectl delete pvc -n monitoring $PROMETHEUS_PVC 2> /dev/null
  fi 
  
  kubectl delete pv pv-prometheus-$PO_NODE 2> /dev/null
  kubectl delete pv pv-grafana-$PO_NODE 2> /dev/null

  kubectl delete storageclass local-storage-prometheus 2> /dev/null
  kubectl delete storageclass local-storage-grafana  2> /dev/null

fi

if [ "$PO_INSTALL" = "yes" ] || ( [ "$PO_INSTALL" = "if_missing" ] && [ "$PO_STATUS" != "deployed" ] )
then
  
  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Prometheus Operator (includes Grafana)...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"
  
  PO_HOST=`kubectl get node $PO_NODE -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`

  #
  # Install...
  #
  # ----------------------------------------------------------------------------  
  log "Installing on node $PO_NODE"
  
  kubectl create namespace monitoring 2> /dev/null
  
  ssh root@$PO_HOST 'mkdir -p /kubernetes-pv/local-storage-prometheus && chmod 777 /kubernetes-pv/local-storage-prometheus'
  ssh root@$PO_HOST 'mkdir -p /kubernetes-pv/local-storage-grafana && chmod 777 /kubernetes-pv/local-storage-grafana'
  
  ssh root@$PO_HOST 'rm -rf /kubernetes-pv/local-storage-prometheus/*'
  ssh root@$PO_HOST 'rm -rf /kubernetes-pv/local-storage-grafana/*'

  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-prometheus
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-grafana
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-prometheus-$PO_NODE
spec:
  capacity:
    storage: 50Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-prometheus
  local:
    path: /kubernetes-pv/local-storage-prometheus
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $PO_HOST
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-grafana-$PO_NODE
spec:
  capacity:
    storage: 20Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-grafana
  local:
    path: /kubernetes-pv/local-storage-grafana
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $PO_HOST              
EOF

    # https://github.com/helm/charts/blob/master/stable/grafana/values.yaml
    cat << EOF > po_values.yaml
grafana:
  dashboardProviders:
    dashboardproviders.yaml:
      apiVersion: 1
      providers:
      - name: hcl-commerce
        orgId: 1
        folder: 'HCL Commerce'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/hcl-commerce      
      - name: hcl-3rdparty
        orgId: 1
        folder: 'HCL Commerce - 3rd Party'
        type: file
        disableDeletion: false
        editable: true
        options:
          path: /var/lib/grafana/dashboards/hcl-3rdparty
  dashboards:
    hcl-commerce:
      nifi-performance:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.3/nifi/nifi-performance.json
        datasource: Prometheus
      store-performance:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_crs_performance.json
        datasource: Prometheus
      java-detailed-metrics-by-pod:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_java_details_by_pod.json
        datasource: Prometheus
      java-metrics-by-pod:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_java_summary_by_pod.json
        datasource: Prometheus
      rest-performance:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_rest_performance.json
        datasource: Prometheus
      hcl-cache-local-cache-details:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_cache_local_details.json
        datasource: Prometheus
      hcl-cache-local-cache-summary:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_cache_local_summary.json
        datasource: Prometheus
      hcl-cache-remote-cache:
        url: $GRAFANA_INTERNAL_REPOSITORY/grafana/9.1.4/hcl_cache_remote.json
        datasource: Prometheus
    hcl-3rdparty:
      nginx:
        url: https://raw.githubusercontent.com/kubernetes/ingress-nginx/master/deploy/grafana/dashboards/nginx.json
        datasource: Prometheus
      redis:
        gnetId: 11835
        datasource: Prometheus
      nifi:
        gnetId: 12375
        datasource: Prometheus
  ingress:
    enabled: true
    hosts: 
    - grafana${DOMAIN}    
  persistence: 
    type: pvc
    enabled: true 
    storageClassName: local-storage-grafana
    accessModes: 
      - ReadWriteOnce 
    size: 1Gi 
    finalizers: 
      - kubernetes.io/pvc-protection
prometheus:
  ingress:
    enabled: true
    hosts: 
    - prometheus${DOMAIN}
  prometheusSpec:
    serviceMonitorSelectorNilUsesHelmValues: false
    serviceMonitorSelector: {}
    storageSpec: 
      volumeClaimTemplate: 
        spec: 
          accessModes: ["ReadWriteOnce"] 
          storageClassName: local-storage-prometheus
          resources: 
            requests: 
              storage: 20Gi 
EOF

  # https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack
  helm install prometheus prometheus-community/kube-prometheus-stack -f po_values.yaml -n monitoring 
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install prometheus prometheus-community/kube-prometheus-stack failed"
    exit 1
  fi
  
  kubectl get pods -o wide -n monitoring

else
  log "Prometheus Operator is installed. Skipping..."   
fi

# -------------------------------------------------------------------------------------------------------
#
#
# Nginx
#
#
# -------------------------------------------------------------------------------------------------------

NGINX_STATUS=`helm status nginx -n nginx 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$NGINX_STATUS" = "deployed" ]
then
  log "Nginx release is pre-installed"
else

  log "Nginx release is not installed"
fi

if [ "$NGINX_INSTALL" = "yes" ] || ( [ "$NGINX_INSTALL" = "if_missing" ] && [ "$NGINX_STATUS" != "deployed" ] )
then

  #
  # Clean up...
  #
  # ----------------------------------------------------------------------------
  
  helm delete nginx -n nginx
  
  #
  # Install...
  #
  # ----------------------------------------------------------------------------

  # https://github.com/kubernetes/ingress-nginx/blob/master/charts/ingress-nginx/values.yaml
  kubectl create namespace nginx 2>/dev/null
    
  cat << EOF > nginx_values.yaml
controller:
  service:
    externalIPs:
    - $MASTER_IP
  metrics:
    enabled: true
    serviceMonitor:
      enabled: true
      
EOF
  
  helm install nginx ingress-nginx/ingress-nginx -n nginx -f nginx_values.yaml  
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install nginx ingress-nginx/ingress-nginx failed"
    exit 1
  fi
  
  kubectl get services nginx-nginx-ingress-controller -n nginx

else
  log "Nginx is installed. Skipping...."
fi


# -------------------------------------------------------------------------------------------------------
#
#
# ZooKeeper  
#
#
# -------------------------------------------------------------------------------------------------------
ZK_STATUS=`helm status zookeeper -n zookeeper 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$ZK_STATUS" = "deployed" ]
then
  log "Zookeper release is pre-installed"
else
  log "Zookeper release is not installed"
fi

if [ -z "$ZK_NODE" ]; then
  ZK_NODE=$MASTER_NODE
fi

if [ "$ZK_INSTALL" = "cleanup" ] || [ "$ZK_INSTALL" = "yes" ] || ( [ "$ZK_INSTALL" = "if_missing" ] && [ "$ZK_STATUS" != "deployed" ] )
then

  #
  # Clean up...
  #
  # ---------------------------------------------------------------------------- 
  
  helm delete zookeeper -n zookeeper 2> /dev/null
  
  ZK_PVC=`kubectl get pvc -n zookeeper -o jsonpath="{.items[0].metadata.name}" 2> /dev/null`
  
  # Delete the Zookeeper claim
  if [ -n "$ZK_PVC" ]; then
    kubectl patch pvc -n zookeeper $ZK_PVC -p '{"metadata":{"finalizers": []}}' --type=merge
    kubectl delete pvc -n zookeeper $ZK_PVC
  fi

  kubectl delete pv pv-zk-$ZK_NODE 2> /dev/null
  kubectl delete storageclass local-storage-zk 2> /dev/null

fi


if [ "$ZK_INSTALL" = "yes" ] || ( [ "$ZK_INSTALL" = "if_missing" ] && [ "$ZK_STATUS" != "deployed" ] )
then
  
  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing ZooKeeper...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"
  log "Installing on node $ZK_NODE"
  
  ZK_HOST=`kubectl get node $ZK_NODE -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`
  
  
  #
  # Install...
  #
  # ----------------------------------------------------------------------------   
  
  kubectl create namespace zookeeper 2> /dev/null
  
  ssh root@$ZK_HOST 'mkdir -p /kubernetes-pv/local-storage-zk && chmod 777 /kubernetes-pv/local-storage-zk'
  ssh root@$ZK_HOST 'rm -rf /kubernetes-pv/local-storage-zk/*'

  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-zk
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
---
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-zk-$ZK_NODE
spec:
  capacity:
    storage: 20Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-zk
  local:
    path: /kubernetes-pv/local-storage-zk
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $ZK_HOST
EOF
  
  helm install zookeeper bitnami/zookeeper --set persistence.storageClass=local-storage-zk -n zookeeper
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install zokeeper bitnami/zookeeper failed"
    exit 1
  fi  

else
  log "Skipping Zookeeper install"   
fi

# -------------------------------------------------------------------------------------------------------
#
#
# Elastic Search  
#
#
# -------------------------------------------------------------------------------------------------------
ES_STATUS=`helm status elasticsearch -n elastic 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$ES_STATUS" = "deployed" ]
then
  log "Elastic release is pre-installed"
else

  log "Elastic release is not installed"
fi

if [ "$ES_INSTALL" = "cleanup" ] || [ "$ES_INSTALL" = "yes" ] || ( [ "$ES_INSTALL" = "if_missing" ] && [ "$ES_STATUS" != "deployed" ] )
then

  #
  # ES Clean up...
  #
  # ----------------------------------------------------------------------------
  helm delete elasticsearch -n elastic 2> /dev/null 

  for es_pvc in `kubectl get pvc -n elastic -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl patch pvc  -n elastic $es_pvc -p '{"metadata":{"finalizers": []}}' --type=merge 2>/dev/null
    kubectl delete pvc -n elastic $es_pvc 2>/dev/null
  done
  
  for esnode in $CLUSTER_NODE_NAMES
  do
    kubectl delete pv pv-es-$esnode 2>/dev/null
  done

  kubectl delete storageclass local-storage-es 2>/dev/null

fi

if [ "$ES_INSTALL" = "yes" ] || ( [ "$ES_INSTALL" = "if_missing" ] && [ "$ES_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Elastic Search...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  #
  # Install...
  #
  # ---------------------------------------------------------------------------- 
  
  log "Number of Elastic nodes: $ES_NUM_NODES"
  
  if [ "$ES_NUM_NODES" -gt "$CLUSTER_SIZE" ]
  then
    log "ERROR: Invalid number of ES nodes requested ($ES_NUM_NODES) is larger than cluster size $CLUSTER_SIZE"    
    if [ "$CLUSTER_SIZE" -eq 2 ]; then  
      ES_NUM_NODES=1
    else
      ES_NUM_NODES=$CLUSTER_SIZE
    fi
  fi

  kubectl create namespace elastic 2>/dev/null
  
  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-es
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

  for esnode in $CLUSTER_NODE_NAMES
  do

    # if ES_CLUSTER_NODES is defined, and ES_CLUSTER_NODES doesn't contain $esnode, countinue
    if [ -n "$ES_CLUSTER_NODES" ] && [ "$ES_CLUSTER_NODES" =! *"$esnode"* ]; then
       continue
    fi
    
    eshost=`kubectl get node $esnode -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`
    
    ssh root@$eshost 'mkdir -p /kubernetes-pv/local-storage-es && chmod 777 /kubernetes-pv/local-storage-es'
    ssh root@$eshost 'rm -rf /kubernetes-pv/local-storage-es/*'
  
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-es-$esnode
spec:
  capacity:
    storage:  20Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-es
  local:
    path: /kubernetes-pv/local-storage-es
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $eshost
EOF

  done
  
  if [ "$ES_NUM_NODES" -gt 1 ]; then 
  
    cat << EOF > es_values.yaml
replicas: $ES_NUM_NODES
minimumMasterNodes: 2
EOF

  else

    cat << EOF > es_values.yaml
replicas: 1
minimumMasterNodes: 1
EOF
  
  fi

  cat << EOF >> es_values.yaml
imageTag: "7.9.2"
ingress:
  enabled: true
  path: /
  hosts: 
  - es${DOMAIN}
  tls: [] 
volumeClaimTemplate: 
  accessModes: [ "ReadWriteOnce" ] 
  storageClassName: local-storage-es
  resources: 
    requests: 
      storage: 15Gi 
esJavaOpts: "-Xmx5g -Xms5g" 
resources: 
  requests: 
    cpu: 500m 
    memory: "7Gi" 
  limits: 
    cpu: 8 
    memory: "7Gi" 
esConfig: 
  elasticsearch.yml: | 
    indices.fielddata.cache.size: "20%"
    indices.queries.cache.size: "30%"
EOF
  
  helm install elasticsearch elastic/elasticsearch -f es_values.yaml -n elastic
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install elasticsearch elastic/elasticsearch failed"
    exit 1
  fi
  
  if wait_for_ready elastic Elasticsearch
  then
    
    log "Elasticsearch is in ready state"
    kubectl get pods -n elastic -o wide
    
  else  
    log "ERROR: Elasticsearch failed to start"
    exit 1
  fi

else
  log "Elastic installation skipped"
fi


# -------------------------------------------------------------------------------------------------------
#
#
# Kibana
#
#
# -------------------------------------------------------------------------------------------------------

KIBANA_STATUS=`helm status kibana -n elastic 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$KIBANA_STATUS" = "deployed" ]
then
  log "Kibana release is pre-installed"
else

  log "Kibana release is not installed"
fi

if [ "$KIBANA_INSTALL" = "cleanup" ] || [ "$KIBANA_INSTALL" = "yes" ] || ( [ "$KIBANA_INSTALL" = "if_missing" ] && [ "$KIBANA_STATUS" != "deployed" ] )
then

  #
  # Kibana Clean up...
  #
  # ----------------------------------------------------------------------------
  helm delete kibana -n elastic
  
  cat << EOF > kibana_values.yaml
imageTag: "7.9.2"
ingress:
  enabled: true
  annotations:
    #kubernetes.io/ingress.class: gce
    #kubernetes.io/tls-acme: "true"
  path: /
  hosts:
    - kibana${DOMAIN}
  tls: []

EOF

fi

if [ "$KIBANA_INSTALL" = "yes" ] || ( [ "$KIBANA_INSTALL" = "if_missing" ] && [ "$KIBANA_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Kibana...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"
  
  helm install kibana elastic/kibana -n elastic -f kibana_values.yaml
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install kibana elastic/kibana failed"
    exit 1
  fi  
    
else
  log "Kibana installation skipped"
fi

# -------------------------------------------------------------------------------------------------------
#
#
# Redis
#
#
# -------------------------------------------------------------------------------------------------------

REDIS_STATUS=`helm status redis -n redis 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$REDIS_STATUS" = "deployed" ]
then
  log "Redis release is pre-installed"
else

  log "Redis release is not installed"
fi

if [ "$REDIS_INSTALL" = "cleanup" ] || [ "$REDIS_INSTALL" = "yes" ] || ( [ "$REDIS_INSTALL" = "if_missing" ] && [ "$REDIS_STATUS" != "deployed" ] )
then

  #
  # Redis Clean up...
  #
  # ----------------------------------------------------------------------------

  helm delete redis -n redis 2>/dev/null

  for redis_pvc in `kubectl get pvc -n redis -o jsonpath="{.items[*].metadata.name}"`
  do
    kubectl patch pvc  -n redis $redis_pvc -p '{"metadata":{"finalizers": []}}' --type=merge 2>/dev/null
    kubectl delete pvc -n redis $redis_pvc 2>/dev/null
  done
  
  for redisnode in $CLUSTER_NODE_NAMES
  do
    kubectl delete pv pv-redis-$redisnode 2>/dev/null
  done
     
  kubectl delete storageclass local-storage-redis 2>/dev/null
fi

if [ "$REDIS_INSTALL" = "yes" ] || ( [ "$REDIS_INSTALL" = "if_missing" ] && [ "$REDIS_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Redis...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  #
  # Install
  #
  # ----------------------------------------------------------------------------
  kubectl create namespace redis 2>/dev/null  
  
  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-redis
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF

  for redisnode in $CLUSTER_NODE_NAMES
  do

    redishost=`kubectl get node $redisnode -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`
    
    ssh root@$redishost 'mkdir -p /kubernetes-pv/local-storage-redis && chmod 777 /kubernetes-pv/local-storage-redis'
    ssh root@$redishost 'rm -rf /kubernetes-pv/local-storage-redis/*'
  
    cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-redis-$redisnode
spec:
  capacity:
    storage:  20Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-redis
  local:
    path: /kubernetes-pv/local-storage-redis
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $redishost
EOF

  done

#  if [ "$REDIS_CLUSTER" = "true" ]; then
#
#    log "ERROR: Redis Cluster is not fully supported."
#    log "       NiFi Redis Client must be configured to use Redis Cluster"
#    log "       This is not currently supported by the script. This function"
#    log "       will be deprecated in 9.1.4 as NiFi will use HCL Cache"        
#    
#    REDIS_CLUSTER=false
#
#  fi

  if [ -n "$REDIS_PASSWORD" ]; then

    cat << EOF > redis_values.yaml
usePassword: true
password: $REDIS_PASSWORD
EOF
    
  else    
    cat << EOF > redis_values.yaml
usePassword: false
EOF
  fi 

  if [ "$REDIS_CLUSTER" = "true" ]; then
  
    cat << EOF >> redis_values.yaml
cluster:
  nodes: 3
  replicas: 0
usePassword: false
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    selector:
      prometheus: kube-prometheus
redis:
  resources:
    limits:
      cpu: "8"
      memory: 6Gi
    requests:
      cpu: "2"
      memory: 6Gi
  useAOFPersistence: "no"
  configmap: |-
    maxmemory 5000mb
    maxmemory-policy volatile-lru
    slowlog-log-slower-than 10000
    slowlog-max-len 512    
    latency-monitor-threshold 100
    cluster-require-full-coverage no
    save ""
volumePermissions:
  enabled: false
  image:
    registry: docker.io
    repository: bitnami/minideb
    tag: buster
    pullPolicy: IfNotPresent
sysctlImage:
  enabled: true
  mountHostSys: true
  command:
    - /bin/sh
    - -c
    - |-
      install_packages procps
      sysctl -w net.core.somaxconn=10000
      echo never > /host-sys/kernel/mm/transparent_hugepage/enabled
persistence:
  enabled: true
  storageClass: local-storage-redis
EOF

    helm install redis bitnami/redis-cluster -f ./redis_values.yaml -n redis
    if [ $? -ne 0 ]; then    
      log "ERROR: helm install redis bitnami/redis-cluster failed"
      exit 1
    fi   
  
  else 

    cat << EOF >> redis_values.yaml
cluster:
  enabled: false
master:
  disableCommands: ""
  persistence:
    enabled: true
    storageClass: local-storage-redis
  configmap: |-
    appendonly no
    save ""    
    maxmemory 5000mb
    maxmemory-policy volatile-lru    
metrics:
  enabled: true
  serviceMonitor:
    enabled: true
    namespace: redis
sysctlImage:
  enabled: true
  mountHostSys: true
  command:
    - /bin/sh
    - -c
    - |-
      install_packages procps
      sysctl -w net.core.somaxconn=10000
      echo never > /host-sys/kernel/mm/transparent_hugepage/enabled
EOF

    helm install redis bitnami/redis -f ./redis_values.yaml -n redis
    if [ $? -ne 0 ]; then    
      log "ERROR: helm install redis bitnami/redis failed"
      exit 1
    fi  

  fi
  
else
  log "Redis installation skipped"
fi


# -------------------------------------------------------------------------------------------------------
#
#
# Vault
#
#
# -------------------------------------------------------------------------------------------------------

VAULT_STATUS=`helm status vault -n vault 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$VAULT_STATUS" = "deployed" ]
then
  log "Vault release is pre-installed"
else
  log "Vault release is not installed"
fi

if [ "$VAULT_INSTALL" = "cleanup" ] || [ "$VAULT_INSTALL" = "yes" ] || ( [ "$VAULT_INSTALL" = "if_missing" ] && [ "$VAULT_STATUS" != "deployed" ] )
then

  #
  # Vault Clean up...
  #
  # ----------------------------------------------------------------------------

  helm delete vault -n vault 2> /dev/null

fi

if [ "$VAULT_INSTALL" = "yes" ] || ( [ "$VAULT_INSTALL" = "if_missing" ] && [ "$VAULT_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Vault...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  kubectl create namespace vault 2> /dev/null
  kubectl create namespace commerce 2> /dev/null
  
  # remove first space: e.g. .svt.com to svt.com
  VAULT_DOMAIN="${DOMAIN:1}"
  
  if [ "$REDIS_CLUSTER" = "true" ]; then
    redis_host="redis-redis-cluster.redis.svc.cluster.local"
  else
    redis_host="redis-master.redis.svc.cluster.local"
  fi

  # size heap = 75% of the container size
  let nifiJvmHeapMax=( $COMMERCE_NIFI_REQUEST_MEMORY * 75 / 100 )

  cat << EOF > vault_values.yaml
common:
  externalDomain: $VAULT_DOMAIN
  enableIngress: true
vaultConsul:
  vaultData:
    qa:
      both:
        zookeeperHost: zookeeper.zookeeper.svc.cluster.local
        zookeeperPort: 2181
        redisHost: $redis_host
        redisPort: 6379
        nifiJvmHeapInit: 1024m
        nifiJvmHeapMax: ${nifiJvmHeapMax}m
EOF

  if [ -n "$REDIS_PASSWORD" ]; then
  
    if [ -z "$REDIS_PASSWORD_ENCRYPT" ]; then
      log "ERROR: Redis password is set but encrypted password is not"
      exit 1
    fi
    
    cat << EOF >> vault_values.yaml
        redisPasswordEncrypt: $REDIS_PASSWORD_ENCRYPT
EOF
    
  fi 
  
  if [ -n "$COMMERCE_DB_AUTH_IP" ]; then

    cat << EOF >> vault_values.yaml
      auth:
        dbHost: $COMMERCE_DB_AUTH_IP
EOF

  fi

  if [ -n "$COMMERCE_DB_LIVE_IP" ]; then

    cat << EOF >> vault_values.yaml
      live:
        dbHost: $COMMERCE_DB_LIVE_IP
EOF

  fi
  
  helm install vault ./commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul -n vault -f vault_values.yaml
  if [ $? -eq 0 ]; then
    log "Vault is installed: http://vault.$VAULT_DOMAIN "`grep 'vaultToken:' ./commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable/hcl-commerce-vaultconsul/values.yaml`
  else
    log "ERROR: helm install vault failed"
    exit 1
  fi

else
  log "Vault installation skipped"
fi


# -------------------------------------------------------------------------------------------------------
#
#
# Commerce common
#
#
# -------------------------------------------------------------------------------------------------------
COMERCE_COMMON_VALUE_FILE=commerce-common-values.yaml

function commerce_image {

   group=$1
   image=$2   
   
   if [ -z "$3" ]; then
     values="$COMERCE_COMMON_VALUE_FILE"
   else
     values=$3
   fi

   if [ ! -z $image ]; then

      docker_image=`echo $image | sed 's/:.*//'`
      docker_tag=`echo $image | sed 's/.*://'`
      
      gm=`grep -n "${group}:" $COMERCE_COMMON_VALUE_FILE`
      if [ $? -ne 0 ]; then

        # entry does not exist, add it
        echo "" >> $values
        echo "$group:" >> $values
        echo "  image: $docker_image"  >> $values
        echo "  tag: $docker_tag" >> $values
      
      else      
        
        # entry exists, append to it
        linenum=`echo $gm| cut -d : -f 1`
        
        let linenum=$linenum+1
        sed -i "${linenum}i \ \ tag:   $docker_tag"   $COMERCE_COMMON_VALUE_FILE
        sed -i "${linenum}i \ \ image: $docker_image" $COMERCE_COMMON_VALUE_FILE        
      fi
   fi
}


#
# Commerce Common Image configuration
# 
  cat << EOF > $COMERCE_COMMON_VALUE_FILE

license: accept

hclFlexnetURL: "https://flex1513-uat.compliance.flexnetoperations.com"
hclFlexnetID: "G823R1ZAQYDX"
hclFlexnetUserName: "admin"
hclFlexnetUserPassword: "+0ghAf3sfEbxkxO35ybs30o7NTlBektXwtAeeS0FPGo="

common:
  imageRepo: comlnx94.prod.hclpnp.com/
  imagePullPolicy: Always
  dataIngressEnabled: true
  spiUserPwdAes: eNdqdvMAUGRUbiuqadvrQfMELjNScudSp5CBWQ8L6aw=
  spiUserPwdBase64: c3BpdXNlcjpwYXNzdzByZA==
  
  externalDomain: ${DOMAIN}
  tenant: ${COMMERCE_TENANT}
  environmentName: ${COMMERCE_ENV_NAME}  
  searchEngine: $COMMERCE_SEARCH_ENGINE

metrics:
  enabled: true
  serviceMonitor:
    enabled: true

nifiApp:
  persistentVolumeClaim: pvc-nifi
  resources:
    requests:
      cpu: $COMMERCE_NIFI_REQUEST_CPU
      memory: ${COMMERCE_NIFI_REQUEST_MEMORY}Mi
    limits:
      cpu: $COMMERCE_NIFI_LIMIT_CPU
      memory: ${COMMERCE_NIFI_REQUEST_MEMORY}Mi
  
xcApp:
  enabled: false
  
cacheApp:
  enabled: true
  ingress:
    enabled: true

EOF

  cat << EOF >> $COMERCE_COMMON_VALUE_FILE
crsApp:
  enabled: false
EOF

if [ "$REDIS_CLUSTER" = "true" ]; then

  cat << EOF >> $COMERCE_COMMON_VALUE_FILE

hclCache:
  configMap:
    # content for cache_cfg-ext.yaml
    cache_cfg_ext: |-
      redis:
        enabled: true
        yamlConfig: "/SETUP/hcl-cache/redis_cfg.yaml" # Please leave this line untouched
    # content for redis_cfg.yaml
    redis_cfg: |-
      clusterServersConfig:
        idleConnectionTimeout: 10000
        connectTimeout: 5000
        timeout: 500
        retryAttempts: 2
        retryInterval: 500
        subscriptionsPerConnection: 5
        sslProvider: "JDK"
        pingConnectionInterval: 0
        keepAlive: true
        tcpNoDelay: true
        loadBalancer: !<org.redisson.connection.balancer.RoundRobinLoadBalancer> {}
        slaveConnectionMinimumIdleSize: 24
        slaveConnectionPoolSize: 64
        failedSlaveReconnectionInterval: 3000
        failedSlaveCheckInterval: 180000
        masterConnectionMinimumIdleSize: 24
        masterConnectionPoolSize: 64
        subscriptionMode: "MASTER"
        subscriptionConnectionMinimumIdleSize: 1
        subscriptionConnectionPoolSize: 50
        dnsMonitoringInterval: 5000
        nodeAddresses:
        - "redis://redis-redis-cluster-0.redis-redis-cluster-headless.redis.svc.cluster.local:6379"
        - "redis://redis-redis-cluster-1.redis-redis-cluster-headless.redis.svc.cluster.local:6379"
        - "redis://redis-redis-cluster-2.redis-redis-cluster-headless.redis.svc.cluster.local:6379"
        scanInterval: 5000
        password: "${JNDI/ENCRYPTED:REDIS_PASSWORD_ENCRYPT:-}"
      threads: 16
      nettyThreads: 60
      referenceEnabled: true
      transportMode: "NIO"
      lockWatchdogTimeout: 30000
      keepPubSubOrder: true
      useScriptCache: false
      minCleanUpDelay: 5
      maxCleanUpDelay: 1800
      addressResolverGroupFactory: !<org.redisson.connection.DnsAddressResolverGroupFactory> {}

EOF

fi

commerce_image toolingWeb  "$COMMERCE_IMAGE_TOOLING_WEB"
commerce_image storeWeb    "$COMMERCE_IMAGE_STORE_WEB"
commerce_image tsWeb       "$COMMERCE_IMAGE_TS_WEB"
commerce_image crsApp      "$COMMERCE_IMAGE_CRS"
commerce_image ingestApp   "$COMMERCE_IMAGE_INGEST"
commerce_image queryApp    "$COMMERCE_IMAGE_QUERY"
commerce_image tsApp       "$COMMERCE_IMAGE_TS" 
commerce_image cacheApp    "$COMMERCE_IMAGE_CACHE"
commerce_image nifiApp     "$COMMERCE_IMAGE_NIFI" 
commerce_image registryApp "$COMMERCE_IMAGE_REGISTRY"
commerce_image xcApp       "$COMMERCE_IMAGE_XC"
commerce_image supportC    "$COMMERCE_IMAGE_SUPPORTC"

commerce_image searchAppMaster    "$COMMERCE_IMAGE_SEARCH"
commerce_image searchAppSlave     "$COMMERCE_IMAGE_SEARCH"
commerce_image searchAppRepeater  "$COMMERCE_IMAGE_SEARCH"


# -------------------------------------------------------------------------------------------------------
#
#
# Commerce Auth
#
#
# -------------------------------------------------------------------------------------------------------

COMMERCE_AUTH_CONFIGURED=false

COMMERCE_AUTH_STATUS=`helm status ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth -n commerce 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$COMMERCE_AUTH_STATUS" = "deployed" ]
then
  log "Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth release is pre-installed"
else
  log "Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth release is not installed"
fi

if [ "$COMMERCE_AUTH_INSTALL" = "cleanup" ] || [ "$COMMERCE_AUTH_INSTALL" = "yes" ] || ( [ "$COMMERCE_AUTH_INSTALL" = "if_missing" ] && [ "$COMMERCE_AUTH_STATUS" != "deployed" ] )
then

  #
  # Commerce Auth Clean up...
  #
  # ----------------------------------------------------------------------------
  
  log "Cleaning up Commerce auth resources..."
   
  log "Uninstalling ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth..."
  helm delete ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth  -n commerce 2> /dev/null

fi

if [ "$COMMERCE_AUTH_INSTALL" = "yes" ] || ( [ "$COMMERCE_AUTH_INSTALL" = "if_missing" ] && [ "$COMMERCE_AUTH_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  #
  # Install...
  #
  # ----------------------------------------------------------------------------

  log "Installing..."
  
  kubectl create namespace commerce 2> /dev/null  

  log "Installing Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth"
  
  if [ -n "$COMMERCE_DB_AUTH_IP" ]; then
    ts_db_enabled=false
  else
    ts_db_enabled=true
  fi
  
  cp $COMERCE_COMMON_VALUE_FILE commerce-auth-values.yaml
  
  cat << EOF >> commerce-auth-values.yaml
tsDb:
  enabled: $ts_db_enabled
EOF

  commerce_image tsDb "$COMMERCE_IMAGE_TS_DB" commerce-auth-values.yaml
  
  helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth ./commerce-helmchart-master/hcl-commerce-helmchart/stable/hcl-commerce -n commerce -f commerce-auth-values.yaml --set common.environmentType=auth
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth failed"
    exit 1
  fi  
  
  COMMERCE_AUTH_CONFIGURED=true

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth installation completed"
  
else

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth installation skipped"

fi

COMMERCE_AUTH_STATUS=`helm status ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-auth -n commerce 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$COMMERCE_AUTH_STATUS" = "deployed" ]
then
  COMMERCE_USE_AUTH=true
else
  COMMERCE_USE_AUTH=false
fi


# -------------------------------------------------------------------------------------------------------
#
#
# Commerce Share
#
#
# -------------------------------------------------------------------------------------------------------

COMMERCE_SHARE_CONFIGURED=false
COMMERCE_SHARE_STATUS=`helm status ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share -n commerce 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$COMMERCE_SHARE_STATUS" = "deployed" ]
then
  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share is pre-installed"
else
  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share is not installed"
fi

if [ "$COMMERCE_SHARE_INSTALL" = "cleanup" ] || [ "$COMMERCE_SHARE_INSTALL" = "yes" ] || ( [ "$COMMERCE_SHARE_INSTALL" = "if_missing" ] && [ "$COMMERCE_SHARE_STATUS" != "deployed" ] )
then

  #
  # Clean up...
  #
  # ----------------------------------------------------------------------------
  
  log "Cleaning up commerce resources..."
  
  log "Uninstalling ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share..."
  # optional: --no-hooks
  helm delete ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share -n commerce 2> /dev/null

  log "Deleting persistent volumes and claims..."  
  kubectl patch pvc -n commerce  pvc-nifi -p '{"metadata":{"finalizers": []}}' --type=merge 2> /dev/null  
  kubectl delete pvc -n commerce pvc-nifi 2> /dev/null  

  for cnn in $CLUSTER_NODE_NAMES
  do
    kubectl delete pv pv-nifi-$cnn 2> /dev/null
  done
  
  kubectl delete storageclass local-storage-nifi 2> /dev/null
  
fi

if [ "$COMMERCE_SHARE_INSTALL" = "yes" ] || ( [ "$COMMERCE_SHARE_INSTALL" = "if_missing" ] && [ "$COMMERCE_SHARE_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  # As we are re-installing ingest/nifi, delete the old connectors from Zookeeper
  log "Deleting existing connectors from Zookeeper..."
  kubectl exec -n zookeeper zookeeper-0 -- zkCli.sh deleteall /configuration
  kubectl exec -n zookeeper zookeeper-0 -- zkCli.sh deleteall /connectors

  #
  # Install...
  #
  # ----------------------------------------------------------------------------

  log "Installing..."
  
  kubectl create namespace commerce 2> /dev/null
    
  cat <<EOF | kubectl apply -f -
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: local-storage-nifi
provisioner: kubernetes.io/no-provisioner
reclaimPolicy: Delete
volumeBindingMode: WaitForFirstConsumer
EOF
   
  for cnn in $CLUSTER_NODE_NAMES
  do
   
   if [ -n "$COMMERCE_NIFI_NODE" ] && [ "$COMMERCE_NIFI_NODE" != "$cnn"]; then
      continue
   fi
   
   chn=`kubectl get node $cnn -o jsonpath={.status.addresses[?\(@.type==\"Hostname\"\)].address}`
     
   ssh root@$chn 'mkdir -p /kubernetes-pv/local-storage-nifi && chmod 777 /kubernetes-pv/local-storage-nifi'
   ssh root@$chn 'rm -rf /kubernetes-pv/local-storage-nifi/*'
      
   cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nifi-$cnn
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteMany
  persistentVolumeReclaimPolicy: Delete
  storageClassName: local-storage-nifi
  local:
    path: /kubernetes-pv/local-storage-nifi
  nodeAffinity:
    required:
      nodeSelectorTerms:
        - matchExpressions:
          - key: kubernetes.io/hostname
            operator: In
            values:
              - $cnn
EOF
  
  done

  cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: pvc-nifi
 namespace: commerce
spec:
  storageClassName: local-storage-nifi
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 100Gi
EOF

  # https://github02.hclpnp.com/commerce-dev/commerce-helmchart/blob/master/test/ivt/commerce_values/ivt-GMV-9.1.2-ESdb2.yaml  

  helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share ./commerce-helmchart-master/hcl-commerce-helmchart/stable/hcl-commerce -n commerce -f $COMERCE_COMMON_VALUE_FILE --set common.environmentType=share
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share failed"
    exit 1
  fi

  log "Patching ${COMMERCE_TENANT}${COMMERCE_ENV_NAME}data-ingress with new timeouts..."    

  # This is used to avoid 504 Gateway Timeout while creating the connector:
  # nginx.ingress.kubernetes.io~1proxy-connect-timeout: 180
  # nginx.ingress.kubernetes.io~1proxy-read-timeout: 1800
  # nginx.ingress.kubernetes.io~1proxy-send-timeout: 1800
  kubectl patch ingress ${COMMERCE_TENANT}${COMMERCE_ENV_NAME}data-ingress -n commerce --type='json' -p='[{"op": "add", "path": "/metadata/annotations/nginx.ingress.kubernetes.io~1proxy-connect-timeout", "value":"180"},{"op": "add", "path": "/metadata/annotations/nginx.ingress.kubernetes.io~1proxy-read-timeout", "value":"1800"},{"op": "add", "path": "/metadata/annotations/nginx.ingress.kubernetes.io~1proxy-send-timeout", "value":"1800"}]'

  if [ "$COMMERCE_USE_AUTH" = "false" ]; then

    log "Using LIVE for reindexing"
    log "Patching deployment/${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app with ENVTYPE=live to keep it in sync with pre created connectors in Nifi..."
  
    kubectl scale -n commerce deployment/${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app --replicas=0
    kubectl set env deployment/${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app -n commerce ENVTYPE=live
    kubectl scale -n commerce deployment/${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app --replicas=1
    
  else 
  
    log "Using AUTH for reindexing"
  fi

  kubectl delete pod -n commerce `kubectl get pods -n commerce --field-selector status.phase=Succeeded -o jsonpath={.items[*].metadata.name}` 2> /dev/null

  COMMERCE_SHARE_CONFIGURED=true

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share installation completed"
  
else

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-share installation skipped"
fi

# -------------------------------------------------------------------------------------------------------
#
#
# Commerce Live
#
#
# -------------------------------------------------------------------------------------------------------
COMMERCE_LIVE_CONFIGURED=false

COMMERCE_LIVE_STATUS=`helm status ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live -n commerce 2> /dev/null | grep STATUS | sed 's/STATUS: //'`

if [ "$COMMERCE_LIVE_STATUS" = "deployed" ]
then
  log "Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live release is pre-installed"
else
  log "Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live release is not installed"
fi

if [ "$COMMERCE_LIVE_INSTALL" = "cleanup" ] || [ "$COMMERCE_LIVE_INSTALL" = "yes" ] || ( [ "$COMMERCE_LIVE_INSTALL" = "if_missing" ] && [ "$COMMERCE_LIVE_STATUS" != "deployed" ] )
then

  #
  # Commerce Live Clean up...
  #
  # ----------------------------------------------------------------------------
  
  log "Cleaning up Commerce live resources..."
   
  log "Uninstalling ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live..."
  helm delete ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live -n commerce 2> /dev/null

fi

if [ "$COMMERCE_LIVE_INSTALL" = "yes" ] || ( [ "$COMMERCE_LIVE_INSTALL" = "if_missing" ] && [ "$COMMERCE_LIVE_STATUS" != "deployed" ] )
then

  log "# ---------------------------------------------------------------------------------"
  log "#"
  log "#"
  log "# Installing Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live...."
  log "#"
  log "#"
  log "# ---------------------------------------------------------------------------------"

  #
  # Install...
  #
  # ----------------------------------------------------------------------------

  log "Installing..."
  
  kubectl create namespace commerce 2> /dev/null  

  log "Installing Commerce ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live"
  
  cp $COMERCE_COMMON_VALUE_FILE commerce-live-values.yaml
  
  if [ -n "$COMMERCE_DB_LIVE_IP" ]; then
    ts_db_enabled=false
  else
    ts_db_enabled=true
  fi
  
  cat << EOF >> commerce-live-values.yaml
tsDb:
  enabled: $ts_db_enabled
EOF
    
  commerce_image tsDb "$COMMERCE_IMAGE_TS_DB" commerce-live-values.yaml
    
  helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live ./commerce-helmchart-master/hcl-commerce-helmchart/stable/hcl-commerce -n commerce -f commerce-live-values.yaml --set common.environmentType=live
  if [ $? -ne 0 ]; then    
    log "ERROR: helm install ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live failed"
    exit 1
  fi  

  COMMERCE_LIVE_CONFIGURED=true

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live installation completed"
  
else

  log "Commerce release ${COMMERCE_TENANT}-${COMMERCE_ENV_NAME}-live installation skipped"

fi

#
# Host entries
#
# ----------------------------------------------------------------------------

add_host_entry es${DOMAIN}
add_host_entry kibana${DOMAIN}
add_host_entry grafana${DOMAIN}
add_host_entry prometheus${DOMAIN}

add_host_entry vault${DOMAIN}

add_host_entry nifi.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}
add_host_entry ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}
add_host_entry query.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}
add_host_entry registry.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}

for COMMERCE_ENV_TYPE in auth live
do 
  add_host_entry cmc.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry accelerator.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry admin.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry org.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry store.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry search.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry tsapp.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry www.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
  add_host_entry cache.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}
done

log ""
log "**"
log "/etc/host file entries:"
log "-------------------------------------------------"

echo ""
echo "$MASTER_IP es${DOMAIN}"
echo "$MASTER_IP kibana${DOMAIN}"
echo "$MASTER_IP grafana${DOMAIN}"
echo "$MASTER_IP prometheus${DOMAIN}"

echo "$MASTER_IP vault${DOMAIN}"

echo "$MASTER_IP nifi.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}"
echo "$MASTER_IP ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}"
echo "$MASTER_IP query.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}"
echo "$MASTER_IP registry.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}"

for COMMERCE_ENV_TYPE in auth live
do 
  echo "$MASTER_IP cmc.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP accelerator.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP admin.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP org.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP store.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP search.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP tsapp.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP www.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
  echo "$MASTER_IP cache.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${COMMERCE_ENV_TYPE}${DOMAIN}"
done

echo ""
log ""

# -------------------------------------------------------------------------------------------------------
#
#
# Commerce - starting 
#
#
# -------------------------------------------------------------------------------------------------------

if [ "$COMMERCE_SHARE_CONFIGURED" = "true" ] || [ "$COMMERCE_LIVE_CONFIGURED" = "true" ] || [ "$COMMERCE_AUTH_CONFIGURE" = "true" ] || [ "$COMMERCE_FORCE_REINDEX" = "true" ] 
then

  # Remove failed and completed jobs (note if not deleted, the query used in wait_for_ready fails
  # kubectl -n $namespace get pods -o "custom-columns=ready:status.containerStatuses[*].ready" | grep -qE "none|false"
  kubectl delete pod -n commerce `kubectl get pods -n commerce --field-selector status.phase=Failed -o jsonpath={.items[*].metadata.name}` 2> /dev/null
  kubectl delete pod -n commerce `kubectl get pods -n commerce --field-selector status.phase=Succeeded -o jsonpath={.items[*].metadata.name}` 2> /dev/null  

  # if a component (share or live) is not installed 
  # but it is broken, this section will fail
  if wait_for_ready commerce Commerce
  then
    
    log "Commerce is in ready state..."
    kubectl get pods -n commerce -o wide

    log ""
    log "# Commerce Image Labels:"
    log "---------------------------------------------"
    for cpod in `kubectl get pods -n commerce -o jsonpath={.items[*].metadata.name}`
    do
      log ${cpod}: `kubectl exec -n commerce $cpod -- /SETUP/bin/viewlabels`
    done
    log ""

  else 
    log "Commerce failed to start"
    exit 1
  fi
  
  # Wait for Ingest to be ready
  # This is a workaround as the pod doesn't currently reflect the ready state
  # properly
  #
  # Alternative: check curl response
  # curl -f -X GET "http://ingest.demoqa.andres.svt.hcl.com/connectors" -H "accept: application/json"
  # CURLE_HTTP_RETURNED_ERROR : 22    
  # ---------------------------------------------------------------------------- 
  # The Ingest service endpoints are unlocked and ready to accept requests
  #if ingest_log_check "The Ingest service endpoints are unlocked and ready to accept requests" 90
  #then
  #  log "Ingest pod is started"
  #else
  #  log "ERROR: Ingest pod did not start in time"
  #  exit 1
  #fi  

fi # [ "$COMMERCE_SHARE_CONFIGURED" = "true" ] || [ "$COMMERCE_LIVE_CONFIGURED" = "true" ] || [ "$COMMERCE_AUTH_CONFIGURE" = "true" ]


# -------------------------------------------------------------------------------------------------------
#
#
# Commerce - indexing 
#
#
# -------------------------------------------------------------------------------------------------------

if [ "$COMMERCE_SHARE_CONFIGURED" = "true" ]
then  

 if [ "$COMMERCE_USE_AUTH" = "false" ]; then
  
    #
    # Extracting the Connector
    # ---------------------------------------------------------------------------- 
    
    # Extract conector file 
    log "Extracting connector from ${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app..."
    kubectl cp -n commerce `kubectl get pod -n commerce -l component=${COMMERCE_TENANT}${COMMERCE_ENV_NAME}ingest-app -o jsonpath="{.items[0].metadata.name}"`":/profile/apps/search-ingest.ear/search-ingest.war/WEB-INF/classes/deployments/commerce/live-reindex-connector.json" live-reindex-connector.json
    
    #
    # Creating the connector
    # ----------------------------------------------------------------------------
    SECONDS=0
    log ""
    log ""
    log "Uploading/Creating live.reindex connector...."
    log "---------------------------------------------"
    log ""
    curl_resp=`curl -w 'http_code:%{http_code}' -m 1800 -v -X POST -H "accept: application/json" -H "Content-Type: application/json" -d @live-reindex-connector.json "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors"`
    log "$CURL_RESP"
    
    curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
    if [ "$curl_http_status" -ne 201 ]
    then
      log "ERROR: POST /connectors: Unexpected http status response: $curl_http_status"
      exit 1
    fi
    
    duration=$SECONDS
    log "live.reindex connector created in $(($duration / 60)) minutes $(($duration % 60)) seconds."
  
  fi
  
  if [ "$COMMERCE_USE_AUTH" = "true" ]; then
    commerce_tuning_file=$COMMERCE_AUTH_NIFI_TUNING
  else
    commerce_tuning_file=$COMMERCE_LIVE_NIFI_TUNING
  fi  
    
  if [ -f "$commerce_tuning_file" ]; then
    log "Applying NiFi tunning $commerce_tuning_file"
    curl_resp=`curl -w 'http_code:%{http_code}' -v -X PUT -H "Content-Type: application/json" -d @${commerce_tuning_file} "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors"`
    curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
    if [ "$curl_http_status" -ne 204 ]
    then
      log "ERROR: Unexpected http status response for NiFi Tunning update: $curl_http_status"
      exit 1
    fi    
  else
    log "No NiFi tunning applied"
  fi  

fi # if [ "$COMMERCE_SHARE_CONFIGURED" = "true" ]

if [ "$COMMERCE_SHARE_CONFIGURED" = "true" ] || [ "$COMMERCE_FORCE_REINDEX" = "true" ] 
then  
  
  #
  # Running the connector
  # ----------------------------------------------------------------------------      
  if [ "$COMMERCE_USE_AUTH" = "true" ]; then    
    COMMERCE_ENV_TYPE=auth
  else 
    COMMERCE_ENV_TYPE=live
  fi

  COMMERCE_CONNECTOR_NAME=${COMMERCE_ENV_TYPE}".reindex"
  
  log ""
  log ""
  log "Runnning connector ${COMMERCE_CONNECTOR_NAME} ...."
  log ""
  log ""
  
  commerce_connector_creation_start_epoch=`date +'%s'`000
  
  SECONDS=0
  
  curl_resp=`curl -w 'http_code:%{http_code}' -v -X POST -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/${COMMERCE_CONNECTOR_NAME}/run?storeId=$COMMERCE_STORE_ID&envType=${COMMERCE_ENV_TYPE}"`
  log "$curl_resp"
  
  curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
  if [ "$curl_http_status" -ne 202 ]
  then
    log "ERROR: POST /connectors/${COMMERCE_CONNECTOR_NAME}/run: Unexpected http status response: $curl_http_status"
    exit 1
  fi
  
  # curl_resp='{"runId":"607ccc5b-28bc-4332-a810-898bd23643ff"}http_code:202'    
  curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`    
  ingest_connector_run_id=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['runId'])"`
  
  log "Connector running: runId: $ingest_connector_run_id"
  
  #
  # Monitoring connector run progress
  # ----------------------------------------------------------------------------
  
  #{
  #    "date": "2020-10-23T17:00:29.848Z",
  #    "runId": "607ccc5b-28bc-4332-a810-898bd23643ff",
  #    "fromType": "summary",
  #    "message": "Indexing run finished according to Nifi queue being empty for given connector.{\"elapsed\":119,\"codes\":{\"DI1010W\":3},\"start\":\"2020-10-23T16:58:30.018Z\",\"run\":\"607ccc5b-28bc-4332-a810-898bd23643ff\",\"end\":\"2020-10-23T17:00:29.572Z\",\"locations\":{\"warning\":{\"STA Stage 1 (Database), Load STA\":{\"W\":2},\"STA Stage 1 (Database), Find STA\":{\"W\":1}}},\"severities\":{\"W\":3}}",
  #    "status": 0
  #}
  
  ingest_connector_run_completed=0
  ingest_connector_run_loop_num=0
  
  # 10 hours
  while [ $ingest_connector_run_completed -eq 0 ] && [ $ingest_connector_run_loop_num -lt 600 ]
  do      
    # /connectors/{connectorId}/runs/{runId}/status
    curl_resp=`curl -s -w 'http_code:%{http_code}' -X GET -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/${COMMERCE_CONNECTOR_NAME}/runs/$ingest_connector_run_id/status"`
    if [ $? -eq 0 ]; then
      curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
      if [ "$curl_http_status" -eq 200 ]; then
      
        curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`
      
        json_status=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['status'])"`
        json_message=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['message'])"`
        #{"date":"2020-10-23T17:00:29.848Z","runId":"607ccc5b-28bc-4332-a810-898bd23643ff","fromType":"summary","message":"Indexing run finished according to Nifi queue being empty for given connector.{\"elapsed\":119,\"codes\":{\"DI1010W\":3},\"start\":\"2020-10-23T16:58:30.018Z\",\"run\":\"607ccc5b-28bc-4332-a810-898bd23643ff\",\"end\":\"2020-10-23T17:00:29.572Z\",\"locations\":{\"warning\":{\"STA Stage 1 (Database), Load STA\":{\"W\":2},\"STA Stage 1 (Database), Find STA\":{\"W\":1}}},\"severities\":{\"W\":3}}","status":0}http_code:200
        
        log "${COMMERCE_CONNECTOR_NAME}: status: $json_status $json_message"
        if [ "$json_status" -eq 0 ]
        then
          duration=$SECONDS
          commerce_connector_creation_end_epoch=`date +'%s'`000
          ingest_connector_run_completed=1
          
          log "Ingest completed with status 0 in $(($duration / 60)) minutes"
          
          if [ ! -z "$COMMERCE_INGEST_DASHBOARD_UID" ]; then
           log ""
           log "# Ingest Dashboard: "
           log "# http://grafana${DOMAIN}/d/$COMMERCE_INGEST_DASHBOARD_UID/nifi-performance?orgId=1&from=${commerce_connector_creation_start_epoch}&to=${commerce_connector_creation_end_epoch}"
           log ""
          fi
          
        else            
          sleep 60
        fi
      else        
        log "ERROR: GET http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/${COMMERCE_CONNECTOR_NAME}/runs/$ingest_connector_run_id/status"
        log "ERROR: Unexpected http status response: $curl_http_status"
        log "ERROR: $curl_resp"
        exit 1
      fi
      
    else
       log " ERROR: Unable to check connector run status: $curl_resp"
       exit 1
    fi
    let loop_num=$ingest_connector_run_loop_num+1
  done
  
  if [ $ingest_connector_run_completed -eq 0 ]
  then
    log "ERROR Ingest didn't complete successfully"
    exit 1
  fi
    
  #
  # If using auth & live, do push to live
  # ----------------------------------------------------------------------------      
  if [ "$COMMERCE_USE_AUTH" = "true" ] && [ "$COMMERCE_LIVE_STATUS" = "deployed" ]; then    
    
    log ""
    log ""
    log "Runnning connector push-to-live ...."
    log ""
    log ""

    SECONDS=0

    curl -X POST -H "accept: */*" "http://ingest.demoqa.andres.svt.hcl.com/connectors/push-to-live/run?storeId=11&envType=live"
    
    # {"runId":"723ffcb4-4e40-4871-82c1-0146e3268ec2"}http_code:202
    curl_resp=`curl -w 'http_code:%{http_code}' -v -X POST -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/run?storeId=$COMMERCE_STORE_ID&envType=live"`
    log "$curl_resp"
    
    curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
    if [ "$curl_http_status" -ne 202 ]
    then
      log "ERROR: POST /connectors/push-to-live/run: Unexpected http status response: $curl_http_status"
      exit 1
    fi
    
    # curl_resp='{"runId":"607ccc5b-28bc-4332-a810-898bd23643ff"}http_code:202'    
    curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`    
    push_to_live_run_id=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['runId'])"`
    
    log "Push-to_Live running: runId: $push_to_live_run_id"
     
     #
     # Monitoring connector run progress
     # ----------------------------------------------------------------------------
     
     #{
     #    "date": "2020-10-23T17:00:29.848Z",
     #    "runId": "607ccc5b-28bc-4332-a810-898bd23643ff",
     #    "fromType": "summary",
     #    "message": "Indexing run finished according to Nifi queue being empty for given connector.{\"elapsed\":119,\"codes\":{\"DI1010W\":3},\"start\":\"2020-10-23T16:58:30.018Z\",\"run\":\"607ccc5b-28bc-4332-a810-898bd23643ff\",\"end\":\"2020-10-23T17:00:29.572Z\",\"locations\":{\"warning\":{\"STA Stage 1 (Database), Load STA\":{\"W\":2},\"STA Stage 1 (Database), Find STA\":{\"W\":1}}},\"severities\":{\"W\":3}}",
     #    "status": 0
     #}
     
     push_to_live_completed=0
     push_to_live_run_loop_num=0
     
     # 10 hours
     while [ $push_to_live_completed -eq 0 ] && [ $push_to_live_run_loop_num -lt 600 ]
     do      
       # /connectors/{connectorId}/runs/{runId}/status
       curl_resp=`curl -s -w 'http_code:%{http_code}' -X GET -H "accept: */*" "http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/runs/${push_to_live_run_id}/status"`
       if [ $? -eq 0 ]; then
         curl_http_status=`echo $curl_resp | sed 's/.*http_code://g'`
         if [ "$curl_http_status" -eq 200 ]; then
         
           curl_json=`echo $curl_resp | sed 's/http_code:.*//g'`
         
           json_status=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['status'])"`
           json_message=`echo $curl_json | python -c "import sys, json; print(json.load(sys.stdin)['message'])"`
           #{"date":"2020-10-23T17:00:29.848Z","runId":"607ccc5b-28bc-4332-a810-898bd23643ff","fromType":"summary","message":"Indexing run finished according to Nifi queue being empty for given connector.{\"elapsed\":119,\"codes\":{\"DI1010W\":3},\"start\":\"2020-10-23T16:58:30.018Z\",\"run\":\"607ccc5b-28bc-4332-a810-898bd23643ff\",\"end\":\"2020-10-23T17:00:29.572Z\",\"locations\":{\"warning\":{\"STA Stage 1 (Database), Load STA\":{\"W\":2},\"STA Stage 1 (Database), Find STA\":{\"W\":1}}},\"severities\":{\"W\":3}}","status":0}http_code:200
           
           log "push-to-live: status: $json_status $json_message"
           if [ "$json_status" -eq 0 ]
           then
             duration=$SECONDS
             commerce_connector_creation_end_epoch=`date +'%s'`000
             push_to_live_completed=1
             
             log "Push-to-live completed with status 0 in $(($duration / 60)) minutes"
             
           else            
             sleep 60
           fi
         else        
           log "ERROR: GET http://ingest.${COMMERCE_TENANT}${COMMERCE_ENV_NAME}${DOMAIN}/connectors/push-to-live/runs/${push_to_live_run_id}/status"
           log "ERROR: Unexpected http status response: $curl_http_status"
           log "ERROR: $curl_resp"
           exit 1
         fi
         
       else
          log " ERROR: Unable to check connector run status: $curl_resp"
          exit 1
       fi
       let loop_num=$push_to_live_run_loop_num+1
     done
     
     if [ $push_to_live_completed -eq 0 ]
     then
       log "ERROR Push-to-live didn't complete successfully"
       exit 1
     fi

  fi
  
fi # [ "$COMMERCE_SHARE_CONFIGURED" = "true" ] || [ "$COMMERCE_FORCE_REINDEX" = "true" ] 

log "Installed Releases:"
helm list -A

exit 0
