**Prometheus**

**Step -1. Create namespace**

    kubectl create ns monitoring


**Step 2 -Add Repository**

    helm repo add stable https://kubernetes-charts.storage.googleapis.com

**Step 3-On working node - Create the target directory**

    mkdir -p /pv/prometheus

    chmod 777 -R /pv/prometheus

**Step 4-On master node -Create and apply prometheus-local-storage.yaml**

Use the following content to create a file called prometheus-local-storage.yaml to define the the storage class.

    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
     name: prometheus-local-storage
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer

**Step 5-Apply the changes with the below command:**

    kubectl apply -f prometheus-local-storage.yaml

**Step 6-Create Persistent Volume (PV)**

On master node - Use the following steps to create the persistent volume using the local storage class.

Update the name and value with worker node hostname

pv-prometheus-4116-1.yaml:

    apiVersion: v1 

    kind: PersistentVolume 

    metadata: 

      name: pv-prometheus-4149-1 

    spec: 

      capacity: 

        storage: 12Gi 

      volumeMode: Filesystem 

      accessModes: 

      - ReadWriteOnce 

      persistentVolumeReclaimPolicy: Delete 

      storageClassName: prometheus-local-storage

      local: 

        path: /pv/prometheus

      nodeAffinity: 

        required: 

          nodeSelectorTerms: 

          - matchExpressions: 

            - key: kubernetes.io/hostname 

              operator: In 

              values: 

              - comp-4149-1 


**Step 7-Use the create command to define the persistent volume**

    [root@com-kube-master pvs]# kubectl create -f pv-prometheus-4116-1.yaml

     persistentvolume/pv-prometheus-4116-1 created
     
  Grafana
  
  **Step 1-On working node - Create the target directory**

    mkdir -p /pv/grafana

    chmod 777 -R /pv/grafana

**Step 2-On master node -Create and apply grafana-local-storage.yaml**

Use the following content to create a file called grafana-local-storage.yaml to define the the storage class.

    kind: StorageClass
    apiVersion: storage.k8s.io/v1
    metadata:
     name: grafana-local-storage
    provisioner: kubernetes.io/no-provisioner
    volumeBindingMode: WaitForFirstConsumer

**Step 3-Apply the changes with the below command:**

    kubectl apply -f grafana-local-storage.yaml

**Step 4-Create Persistent Volume (PV)**

On master node - Use the following steps to create the persistent volume using the local storage class.

pv-grafana-4114-1.yaml:

    apiVersion: v1 

    kind: PersistentVolume 

    metadata: 

      name: pv-grafana-4149-1

    spec: 

      capacity: 

        storage: 2Gi 

      volumeMode: Filesystem 

      accessModes: 

      - ReadWriteOnce 

      persistentVolumeReclaimPolicy: Delete 

      storageClassName: grafana-local-storage

      local: 

        path: /pv/grafana

      nodeAffinity: 

        required: 

          nodeSelectorTerms: 

          - matchExpressions: 

            - key: kubernetes.io/hostname 

              operator: In 

              values: 

              - comp-4149-1 


**Step 7-Use the create command to define the persistent volume**

    [root@com-kube-master pvs]# kubectl create -f pv-grafana-4114-1.yaml
    
    persistentvolume/pv-grafana-4114-1 created
     

**Create StorageSpec Values**

In this step you can customize values.yaml to specify a new storageSpec that refers to the newly created storagespec

    [root@com-kube-master pvs]# vi values.yaml

       grafana: 

      persistence: 

        type: pvc 

        enabled: true 

        storageClassName: grafana-local-storage 

        accessModes: 

          - ReadWriteOnce 

        size: 1Gi 

        finalizers: 

          - kubernetes.io/pvc-protection 
 

    prometheus: 

      prometheusSpec: 

        storageSpec: 

          volumeClaimTemplate: 

            spec: 

              # Name of the PV you created beforehand 

              #volumeName: prometheus-pv 

              accessModes: ["ReadWriteOnce"] 

              # StorageClass should match your existing PV's storage class 

              storageClassName: prometheus-local-storage 

              resources: 

                requests: 

                  # Size below should match your existing PV's size 

                  storage: 10Gi 

Note the following

volumeName & storageClassName should be the same as created above.

storage size- Define as per the requirement

**Install using Helm**

Helm command to create the operator release

 helm install prometheus stable/prometheus-operator -f  values.yaml -n monitoring --set prometheus.ingress.enabled=true --set grafana.ingress.enabled=true --set prometheus.ingress.hosts[0]=prometheus.mycompany.com --set grafana.ingress.hosts[0]=grafana.mycompany.com  --set server.storageClass=local-storage
    
    Update the mycompany to domain name
    
 **Verify the below**  
  
      [root@COMP-4115-1 ~]# kubectl get pvc -n monitoring
    NAME                                                                                                     STATUS   VOLUME                 CAPACITY   ACCESS MODES   STORAGECLASS               AGE
    prometheus-grafana                                                                                       Bound    pv-grafana-4114-1      2Gi        RWO            grafana-local-storage      88s
    prometheus-prometheus-prometheus-oper-prometheus-db-prometheus-prometheus-prometheus-oper-prometheus-0   Bound    pv-prometheus-4116-1   12Gi       RWO            prometheus-local-storage   73s
    
    [root@COMP-4115-1 ~]# kubectl get pods -n monitoring
    NAME                                                     READY   STATUS    RESTARTS   AGE
    alertmanager-prometheus-prometheus-oper-alertmanager-0   2/2     Running   0          109s
    prometheus-grafana-77449fbc9-hrj4d                       2/2     Running   0          114s
    prometheus-kube-state-metrics-c65b87574-87vp6            1/1     Running   0          114s
    prometheus-prometheus-node-exporter-7btvs                1/1     Running   0          114s
    prometheus-prometheus-node-exporter-lk8l8                1/1     Running   0          114s
    prometheus-prometheus-node-exporter-rftlz                1/1     Running   0          114s
    prometheus-prometheus-oper-operator-769d757547-rppln     2/2     Running   0          114s
    prometheus-prometheus-prometheus-oper-prometheus-0       3/3     Running   0          99s
    
   **Update the Service Monitor**
   Kubectl edit prometheus -n monitoring 
   f:serviceMonitorSelector: {}

