#!/bin/bash

# comp-2888-1
DOCKER_REPOSITORY=10.190.66.117

LOAD_REDIS=true
LOAD_VAULT=true
LOAD_ZOOKEEPER=true
LOAD_ELASTIC=true
LOAD_PROMETHEUS=true

# To do: nginx and others

ssh root@${DOCKER_REPOSITORY} -o PasswordAuthentication=no 'test 1'
if [ $? -ne 0 ]; then
  echo "** ERROR: Unable to ssh to docker repository ${DOCKER_REPOSITORY} without password"
  echo "** Use ssh-copy-id to add "
  echo "**    ssh-copy-id -i ~/.ssh/id_rsa.pub ${DOCKER_REPOSITORY}"
fi

if [ -n "${DOCKER_REPOSITORY}" ]; then
  echo "** Loading images from ${DOCKER_REPOSITORY}"
else
  echo "** ERROR: Docker repository is not set"
  exit 1
fi

#
# Redis
#
if [ "${LOAD_REDIS}" = "true" ]
then  
  echo "** Loading Redis..."
  # new redis:
  # bitnami/redis-cluster:6.0.12-debian-10-r0
  ssh ${DOCKER_REPOSITORY} 'docker save bitnami/redis:6.0.9-debian-10-r38 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save bitnami/redis-cluster:6.0.9-debian-10-r38 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save bitnami/redis-exporter:1.13.1-debian-10-r32 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save bitnami/minideb:buster | bzip2' |  bunzip2 | docker load
fi

#
# Vault
#
if [ "${LOAD_VAULT}" = "true" ]
then
  echo "** Loading Vault..."
  ssh ${DOCKER_REPOSITORY} 'docker save docker.io/consul:1.7.1 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save docker.io/vault:1.3.3 | bzip2' |  bunzip2 | docker load
fi

#
# ZooKeeper
#
if [ "${LOAD_ZOOKEEPER}" = "true" ]
then
  echo "** Loading ZooKeeper..."
  ssh ${DOCKER_REPOSITORY} 'docker save bitnami/zookeeper:3.6.2-debian-10-r124 | bzip2' |  bunzip2 | docker load
fi

#
# Elastic and Kibana
#
if [ "${LOAD_ELASTIC}" = "true" ]
then
  echo "** Loading Elastic and Kibana..."
  ssh ${DOCKER_REPOSITORY} 'docker save docker.elastic.co/kibana/kibana:7.9.2 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save docker.elastic.co/elasticsearch/elasticsearch:7.9.2 | bzip2' |  bunzip2 | docker load
fi

#
# Prometheus and Grafana
#
if [ "${LOAD_PROMETHEUS}" = "true" ]
then  
  echo "** Loading Prometheus/Grafana..."
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/prometheus-operator/prometheus-config-reloader:v0.42.1 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/prometheus-operator/prometheus-operator:v0.42.1 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save kiwigrid/k8s-sidecar:0.1.209 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/prometheus/prometheus:v2.21.0 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save jimmidyson/configmap-reload:v0.4.0 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/prometheus/alertmanager:v0.21.0 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/prometheus/node-exporter:v1.0.1 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save quay.io/coreos/kube-state-metrics:v1.9.7 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save busybox:1.31.1 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save curlimages/curl:7.70.0 | bzip2' |  bunzip2 | docker load
  ssh ${DOCKER_REPOSITORY} 'docker save squareup/ghostunnel:v1.5.2 | bzip2' |  bunzip2 | docker load
fi

echo "** All done!"

exit 0
