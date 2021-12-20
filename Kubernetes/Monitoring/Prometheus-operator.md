## Prometheus Operator Install

 

Here, Prometheus is installed with persistent storage so that recorded data can survive pod restarts. The Storage Class 'local-storage' is used which maps to a directory created on the node designated in the persistent volume declaration. 

 

Note: In a production environment it is preferable to use network storage. Local storage is easier to configure with VMs (instead of e.g. glusterfs or NFS). 

Keep in mind that with local storage the pod can only run on the node that defines the storage 
 
GRAFANA PERSISTEN STEPS ARE UNTESTED- THEY ARE NEEDED SO THE DASHBOARDS ARE NOT LOST 

  

Overview: 

Create a target directory 

Create a storageClass (local-storage) 

Create a Persistent Volume (PV) 

Create a storageSpec using values.yaml override 

Issue helm install 

Edit etc/hosts to configure dashboard URLs 

  

Create the target directory 

 

mkdir -p /pv/pv1 

chmod 777 -R /pv/pv1 

 
mkdir -p /pv/pv2 

chmod 777 -R /pv/pv2 

  

Create and apply local-storage.yaml 

 

Use the following content to create a file called local-storage.yaml to define the the storage class 
and apply it 
 

kind: StorageClass 

apiVersion: storage.k8s.io/v1 

metadata: 

  name: local-storage 

provisioner: kubernetes.io/no-provisioner 

volumeBindingMode: WaitForFirstConsumer 
 

Apply the changes as follows: 
 
kubectl apply -f local-storage.yaml 

 

Create Persistent Volumes (PV) 

 

Use the following steps to create the persistent volume using the local storage class.  
 

 
apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: pv2 

spec: 

  capacity: 

    storage: 1Gi 

  volumeMode: Filesystem 

  accessModes: 

  - ReadWriteOnce 

  persistentVolumeReclaimPolicy: Delete 

  storageClassName: local-storage 

  local: 

    path: /pv/pv2 

  nodeAffinity: 

    required: 

      nodeSelectorTerms: 

      - matchExpressions: 

        - key: kubernetes.io/hostname 

          operator: In 

          values: 

          - com-kube-master.nonprod.hclpnp.com 

  

Note the following: 

Name – arbitrary  

StorageClassName – use local-storage 

Path – specify the directory path  

NodeAffinity – specify the node which hosts the shared directory 

  
Use the create command to define the persistent volumne: 
 

[root@com-kube-master pvs]# kubectl create -f pv.yaml 

persistentvolume/pv1 created 
persistentvolume/pv2 created 
 

   

Create storageSpec values.yaml override 

 

In this step you customize values.yaml to specify a new storageSpec that refers to the newly created storagespec 
 
https://github.com/helm/charts/blob/master/stable/grafana/values.yaml (grafana steps untested) 

 

[root@com-kube-master pvs]# vi values.yaml 
 
 

grafana: 

  persistence: 

    type: pvc 

    enabled: true 

    storageClassName: local-storage 

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

          storageClassName: local-storage 

          resources: 

            requests: 

              # Size below should match your existing PV's size 

              storage: 20Gi 

  

Note the following 

volumeName 

storageClassName 

storage size 

  

Issue helm install, providing 

 

Issue the helm command to create the operator release 

 

kubectl create ns monitoring 
helm install stable/prometheus-operator -f values.yaml --name prometheus --namespace monitoring --set prometheus.ingress.enabled=true --set grafana.ingress.enabled=true --set prometheus.ingress.hosts[0]=prometheus.local --set grafana.ingress.hosts[0]=grafana.local 
 

Helm3:0 syntax: 
helm install prometheus stable/prometheus-operator … 

 
 

For the hostnames, instead of using grafana.local, prometheus.local, append an environment identifier, such as. grafana.svt1.local. This will make it easier 
to access multiple environments from the same machine 

  

Update your hosts file 

 

You must update your host file to allow access to the prometheus and grafana dashboard. Use the IP of your nginx ingress 

 

10.190.67.xx grafana.local prometheus.local 

 

 

Validating the install 

 

You can check the directories used by the PV to confirm data is being written 

 

[root@com-kube-node1 ~]# du /pv -m 

128     /pv/prometheus/prometheus-db/wal 

128     /pv/prometheus/prometheus-db 

128     /pv/prometheus 

128     /pv 

 

Dashboard URLs: 

Grafana Dashboard:  
https://grafana.local/?orgId=1 

Default user:  
admin/prom-operator 

Prometheus Dashboard:  
https://prometheus.local 

 

Reference:  

https://github.com/helm/charts/tree/master/stable/prometheus-operator 

https://github.com/helm/charts/issues/9288 

 
