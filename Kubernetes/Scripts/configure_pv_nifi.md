
# Configuring Persistence for NiFi

1. Choose the node you want NiFi to run on
2. Create a directory to hold the persistent volumne
```
mkdir -p /pv/nifi
```
3. Create a storage class for it

```
kind: StorageClass
apiVersion: storage.k8s.io/v1
metadata:
  name: nifi-local-storage
provisioner: kubernetes.io/no-provisioner
volumeBindingMode: WaitForFirstConsumer
```

( we use a storage class with nifi so we have more control over what PV uses)

4. Load the storage class
```
kubectl apply -f local-storage.yaml
```
5. Define the Persistent Volume

Check the size (100Gi in this example) and the node name YOUR_NODE_NAME - the node name needs to match the machine where you create the directory
Also replace <hostname> in the name for the actual node name. This is done to be able to tell more easily on which node it is running 

```
apiVersion: v1
kind: PersistentVolume
metadata:
  name: pv-nifi-<nodename>
spec:
  capacity:
    storage: 100Gi
  volumeMode: Filesystem
  accessModes:
  - ReadWriteOnce
  persistentVolumeReclaimPolicy: Delete
  storageClassName: nifi-local-storage
  local:
    path: /pv/nifi
  nodeAffinity:
    required:
      nodeSelectorTerms:
      - matchExpressions:
        - key: kubernetes.io/hostname
          operator: In
          values:
          - YOUR_NODE_NAME
```
6. Create the Persistent Volume
```
kubectl apply -f nifi-pv.yaml
```
 
7. Define a persistent volume claim for it

```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
 name: nifi-pvc
spec:
  storageClassName: nifi-local-storage
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 100Gi
```

8. Define the Persistent Volume Claim

```
kubectl apply -f nifi-pvc.yaml -n commerce
```

9. Ensure the PVC is defined in values.yaml

e.g. "persistentVolumeClaim: nifi-pvc"

```
nifiApp:
  name: nifi-app
  image: commerce/search-nifi-app
  tag: v9-latest
  replica: 1
  resources:
    requests:
      memory: 5120Mi
      cpu: 500m
    limits:
      memory: 7168Mi
      cpu: 2
  ## when using custom envParameters, use key: value format
  envParameters: {}
  nodeLabel: ""
  persistentVolumeClaim: nifi-pvc
  fileBeatConfigMap: ""
```






