Create namespace 
 
kubectl create ns es 
 

Create local storage class (local-storage.yaml) 
 

kind: StorageClass 

apiVersion: storage.k8s.io/v1 

metadata: 

  name: local-storage 

provisioner: kubernetes.io/no-provisioner 

volumeBindingMode: WaitForFirstConsumer 
 

Define the storage class 
 
kubectl apply -f local-storage.yaml 
 

Create a directory on all the nodes to contain ES data 
 
mkdir -p /pv/es 
 

Define the persistence volumes. Once for each that is to run ES node. 
You need to define one for each node in your cluster. Change the name 
and the node name for each.  
The following example has 3 nodes, comlnx91, comlnx92 and comlnx93. 
 

apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: es-pv-91 

spec: 

  capacity: 

    storage: 20Gi 

  volumeMode: Filesystem 

  accessModes: 

  - ReadWriteOnce 

  persistentVolumeReclaimPolicy: Delete 

  storageClassName: local-storage 

  local: 

    path: /pv/es 

  nodeAffinity: 

    required: 

      nodeSelectorTerms: 

        - matchExpressions: 

          - key: kubernetes.io/hostname 

            operator: In 

            values: 

              - comlnx91 

--- 
apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: es-pv-92 

spec: 

  capacity: 

    storage: 20Gi 

  volumeMode: Filesystem 

  accessModes: 

  - ReadWriteOnce 

  persistentVolumeReclaimPolicy: Delete 

  storageClassName: local-storage 

  local: 

    path: /pv/es 

  nodeAffinity: 

    required: 

      nodeSelectorTerms: 

        - matchExpressions: 

          - key: kubernetes.io/hostname 

            operator: In 

            values: 

              - comlnx92 

--- 
apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: es-pv-93 

spec: 

  capacity: 

    storage: 20Gi 

  volumeMode: Filesystem 

  accessModes: 

  - ReadWriteOnce 

  persistentVolumeReclaimPolicy: Delete 

  storageClassName: local-storage 

  local: 

    path: /pv/es 

  nodeAffinity: 

    required: 

      nodeSelectorTerms: 

        - matchExpressions: 

          - key: kubernetes.io/hostname 

            operator: In 

            values: 

              - comlnx93 

 
 

Define the persistent volumes 
 
kubectl apply -f es-pv.yaml 
 

Create values.yaml file.  Change the domain of ingress to match your environment. Remember you will need to define 
it in the host file in windows or your client 
 
ingress: 

  enabled: true 

  path: / 

  hosts: 

    - es.svt5.hcl.com 

  tls: [] 
 

volumeClaimTemplate: 

  accessModes: [ "ReadWriteOnce" ] 

  storageClassName: local-storage 

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

 

 

Install ES with helm. Using https://github.com/elastic/helm-charts/tree/master/elasticsearch 
 
helm repo add elastic https://helm.elastic.co 
helm install elasticsearch elastic/elasticsearch -f values.yaml -n es 
 

Ensure all persistent volumes are bound 
 

[root@comlnx91 elastic]# kubectl get pvc -n es 

NAME                                          STATUS   VOLUME     CAPACITY   ACCESS MODES   STORAGECLASS    AGE 

elasticsearch-master-elasticsearch-master-0   Bound    es-pv-92   10Gi       RWO            local-storage   12m 

elasticsearch-master-elasticsearch-master-1   Bound    es-pv-93   10Gi       RWO            local-storage   12m 

elasticsearch-master-elasticsearch-master-2   Bound    es-pv-91   10Gi       RWO            local-storage   12 

 

Ensure ES pods are up and running (1/1) 
 

[root@comlnx91 elastic]# kubectl get pods -n es 

NAME                     READY   STATUS    RESTARTS   AGE 

elasticsearch-master-0   1/1     Running   0          14m 

elasticsearch-master-1   1/1     Running   0          14m 

elasticsearch-master-2   1/1     Running   0          14m 
 

As Ingress is defined, you should be able to use curl to open Elastic. Remember to define the host in your hosts file. 
 

curl http://es.svt5.hcl.com/ 

{ 

  "name" : "elasticsearch-master-0", 

  "cluster_name" : "elasticsearch", 

  "cluster_uuid" : "_Q6mB0v3TlGA5tnOicNEtg", 

  "version" : { 

    "number" : "7.6.2", 

    "build_flavor" : "default", 

    "build_type" : "docker", 

    "build_hash" : "ef48eb35cf30adf4db14086e8aabd07ef6fb113f", 

    "build_date" : "2020-03-26T06:34:37.794943Z", 

    "build_snapshot" : false, 

    "lucene_version" : "8.4.0", 

    "minimum_wire_compatibility_version" : "6.8.0", 

    "minimum_index_compatibility_version" : "6.0.0-beta1" 

  }, 

  "tagline" : "You Know, for Search" 

} 
 
 

Ingress runs on port 80, but it's possible to add port 9200 to the service. Use: 
kubectl edit svc -n nginx my-nginx-nginx-ingress-controller 
 
add under ports: 

  - name: eshtpp 

    port: 9200 

    protocol: TCP 

    targetPort: http 

 

 

Uninstalling 
 

helm delete elasticsearch -n es 

 

Empty the /pv/es directory on ALL the nodes 
rm -rf /pv/es/nodes 

 

kubectl delete pvc elasticsearch-master-elasticsearch-master-0 elasticsearch-master-elasticsearch-master-1 elasticsearch-master-elasticsearch-master-2 -n es 
kubectl delete pv es-pv-91 es-pv-92 es-pv-93 
