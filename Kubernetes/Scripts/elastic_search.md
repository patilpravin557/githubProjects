**Elastic Search**

Step -1. Create namespace

        kubectl create ns elastic

Step-2. Create local storage class (es-local-storage.yaml)


        kind: StorageClass

        apiVersion: storage.k8s.io/v1

        metadata:

          name: es-local-storage

        provisioner: kubernetes.io/no-provisioner

        volumeBindingMode: WaitForFirstConsumer


Step-3. Define the storage class

        kubectl apply -f es-local-storage.yaml

Step-4. Create a directory on the worker node to contain ES data

   One node is sufficient for personal use and for doing testing you need to create the directory on every node.

        mkdir -p /pv/es


Step-5. Create the persistence volumes. pv-es-4116-1-1.yaml


        apiVersion: v1 

        kind: PersistentVolume 

        metadata: 

          name: pv-es-4116-1 

        spec: 

          capacity: 

            storage: 20Gi 

          volumeMode: Filesystem 

          accessModes: 

          - ReadWriteOnce 

          persistentVolumeReclaimPolicy: Delete 

          storageClassName: es-local-storage 

          local: 

            path: /pv/es 

          nodeAffinity: 

            required: 

              nodeSelectorTerms: 

                - matchExpressions: 

                  - key: kubernetes.io/hostname 

                    operator: In 

                    values: 

                      - comp-4116-1

You need to define one for each node in your cluster

          apiVersion: v1 

        kind: PersistentVolume 

        metadata: 

          name: pv-es-4115-1 

        spec: 

          capacity: 

            storage: 20Gi 

          volumeMode: Filesystem 

          accessModes: 

          - ReadWriteOnce 

          persistentVolumeReclaimPolicy: Delete 

          storageClassName: es-local-storage 

          local: 

            path: /pv/es 

          nodeAffinity: 

            required: 

              nodeSelectorTerms: 

                - matchExpressions: 

                  - key: kubernetes.io/hostname 

                    operator: In 

                    values: 

                      - comp-4115-1

    apiVersion: v1 

        kind: PersistentVolume 

        metadata: 

          name: pv-es-4115-1 

        spec: 

          capacity: 

            storage: 20Gi 

          volumeMode: Filesystem 

          accessModes: 

          - ReadWriteOnce 

          persistentVolumeReclaimPolicy: Delete 

          storageClassName: es-local-storage 

          local: 

            path: /pv/es 

          nodeAffinity: 

            required: 

              nodeSelectorTerms: 

                - matchExpressions: 

                  - key: kubernetes.io/hostname 

                    operator: In 

                    values: 

                      - comp-4115-1

Step-6. Define the persistent volumes

        kubectl apply -f pv-es-4116-1-1.yaml

Step-7. Create values.yaml file.  Change the domain of ingress to match your environment. Define it in the host file in windows or your client

      
        ingress: 

          enabled: true 

          path: / 

          hosts: 

            - es.svt5.hcl.com 

          tls: [] 


        volumeClaimTemplate: 

          accessModes: [ "ReadWriteOnce" ] 

          storageClassName: es-local-storage 

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



Step-8. Install ES with helm. 

Using [https://github.com/elastic/helm-charts/tree/master/elasticsearch](https://github.com/elastic/helm-charts/tree/master/elasticsearch)

    helm repo add elastic https://helm.elastic.co
    helm install elasticsearch elastic/elasticsearch -f values.yaml -n elastic

Step-9. Ensure all persistent volumes are in Bound Status


        [root@comlnx91 elastic]# kubectl get pvc -n elastic

        NAME                                          STATUS   VOLUME         CAPACITY   ACCESS MODES   STORAGECLASS       AGE
        elasticsearch-master-elasticsearch-master-0   Bound    pv-es-4114-1   20Gi       RWO            es-local-storage   22h
        elasticsearch-master-elasticsearch-master-1   Bound    pv-es-4115-1   20Gi       RWO            es-local-storage   22h
        elasticsearch-master-elasticsearch-master-2   Bound    pv-es-4116-1   20Gi       RWO            es-local-storage   22h


Step-10. Ensure ES pods are up and running (1/1)


        [root@comlnx91 elastic]# kubectl get pods -n elastic

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

Ingress runs on port 80, but it's possible to add port 9200 to the service
           
           kubectl edit svc -n nginx my-nginx-nginx-ingress-controller

    add under ports:

    - name: eshtpp

        port: 9200

        protocol: TCP

        targetPort: http



**Uninstalling**


helm uninstall elasticsearch -n es

Empty the /pv/es directory on ALL the nodes
       
       rm -rf /pv/es/nodes

    kubectl delete pvc elasticsearch-master-elasticsearch-master-0 elasticsearch-master-elasticsearch-master-1 elasticsearch-master-elasticsearch-master-2 -n es
    
    kubectl delete pv pv-es-4114-1  pv-es-4115-1  pv-es-4116-1 
