# Install cloud sdk
install on powershell 
https://cloud.google.com/sdk/docs/quickstart 
# Install helm using chocolatey
* https://chocolatey.org/
* choco install kubernetes-helm
# Install Kubernetes
 gcloud components install kubectl

# Setup your laptop by running the following commands
* gcloud init
* gcloud auth login
# Create db2 VM
### Create instance
	Machine type: n2d-standard-8 (8 vCPUs, 32 GB memory)
	Network tags: allow-ssh, db2-server, perf-cluster3-db2
	Boot disk: SSD 200G
	OS: rhel-7-v20210420 
	Additional disk: SSD 500G
### Setup the disk 
	[noureddine.brahimi@perf-cluster-6-db2-1 ~]$ sudo lsblk
		NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
		sda      8:0    0   200G  0 disk
		├─sda1   8:1    0   200M  0 part /boot/efi
		└─sda2   8:2    0 199.8G  0 part /
		sdb      8:16   0   500G  0 disk
	[noureddine.brahimi@perf-cluster-6-db2-1 ~]$ sudo mkdir -p /mnt/disks/db/dbpath
	[noureddine.brahimi@perf-cluster-6-db2-1 ~]$ sudo su -
	[root@perf-cluster-6-db2-1 ~]# sudo mount -o discard,defaults /dev/sdb /mnt/disks/db/dbpath
	[root@perf-cluster-6-db2-1 ~]# sudo chmod a+w /mnt/disks/db/dbpath
	[root@perf-cluster-6-db2-1 ~]# sudo lsblk
		NAME   MAJ:MIN RM   SIZE RO TYPE MOUNTPOINT
		sda      8:0    0   200G  0 disk
		├─sda1   8:1    0   200M  0 part /boot/efi
		└─sda2   8:2    0 199.8G  0 part /
		sdb      8:16   0   500G  0 disk /mnt/disks/db/dbpath
	[root@perf-cluster-6-db2-1 ~]# sudo cp /etc/fstab /etc/fstab.backup
	[root@perf-cluster-6-db2-1 ~]# sudo blkid /dev/sdb
		/dev/sdb: UUID="5f1b615f-9936-4890-b821-c94e15f6e01a" TYPE="ext4"
		[root@perf-cluster-6-db2-1 ~]# echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/disks/db/dbpath ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab
		UUID=5f1b615f-9936-4890-b821-c94e15f6e01a /mnt/disks/db/dbpath ext4 discard,defaults,nofail 0 2
	[root@perf-cluster-6-db2-1 ~]# cat /etc/fstab
		#
		# /etc/fstab
		# Created by anaconda on Mon Apr 19 17:28:07 2021
		#
		# Accessible filesystems, by reference, are maintained under '/dev/disk'
		# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info
		#
		UUID=52caf522-02e2-49ae-b12e-99851ee058e8 /                       xfs     defaults        0 0
		UUID=DA68-F901          /boot/efi               vfat    defaults,uid=0,gid=0,umask=0077,shortname=winnt 0 0
		UUID=5f1b615f-9936-4890-b821-c94e15f6e01a /mnt/disks/db/dbpath ext4 discard,defaults,nofail 0 2
	[root@perf-cluster-6-db2-1 ~]# sudo lsblk
		NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT
		sda 8:0 0 200G 0 disk
		├─sda1 8:1 0 200M 0 part /boot/efi
		└─sda2 8:2 0 199.8G 0 part /
		sdb 8:16 0 500G 0 disk /mnt/disks/db/dbpath

### Install Db2 and needed libraries and apply the license
    On the VM, run 		gsutil ls gs://hclinstallfiles
	Copy this file 		gs://hclinstallfiles/v11.5_linuxx64_dec.tar 
	- Install db2 
		[root@perf-cluster-6-db2-1 ~]# cd /mnt/disks/db/dbpath
		[root@perf-cluster-6-db2-1 dbpath]# mkdir db2_install_image
		[root@perf-cluster-6-db2-1 db2_install_image]# sudo gsutil cp gs://hclinstallfiles/v11.5_linuxx64_dec.tar  db2_install_image
		[root@perf-cluster-6-db2-1 db2_install_image]# tar -xvf v11.5_linuxx64_dec.tar
		[root@perf-cluster-6-db2-1 db2_install_image]# cd server_dec
		[root@perf-cluster-6-db2-1 server_dec]# ./db2_install
			Requirement not matched for DB2 database "Server" . Version: "11.5.0.0".
			Summary of prerequisites that are not met on the current system:
			   DBT3514W  The db2prereqcheck utility failed to find the following 32-bit library file: "/lib/libpam.so*".
			DBT3609E  The db2prereqcheck utility could not find the library file libnuma.so.1.
			DBT3520E  The db2prereqcheck utility could not find the library file libaio.so.1.
			DBT3514W  The db2prereqcheck utility failed to find the following 32-bit library file: "libstdc++.so.6".
			  Aborting the current installation ...
			  Run installation with the option "-f sysreq" parameter to force the installation.
		[root@perf-cluster-6-db2-1 server_dec]# ./db2_install -f sysreq	  
		[root@perf-cluster-6-db2-1 server_dec]# yum list libaio
		[root@perf-cluster-6-db2-1 server_dec]# yum install libaio.x86_64
		[root@perf-cluster-6-db2-1 server_dec]# yum list numactl-libs
		[root@perf-cluster-6-db2-1 server_dec]# yum install numactl-libs.x86_64
		[root@perf-cluster-6-db2-1 server_dec]# su - db2inst1
		[db2inst1@perf-cluster-6-db2-1 db2inst1]# db2start
		[db2inst1@perf-cluster-6-db2-1 db2inst1]# cd sqllib/adm
		[db2inst1@perf-cluster-6-db2-1 adm]# db2licm -a /mnt/disks/db/dbpath/db2_install_image/ses/db2/db2ses_t.lic

- Create wcs userid 
	   
       Connect to the db server, su to root and run
   	   [root@perf-cluster-6-db2-1 ~]# useradd -g db2iadm1 wcs
	   [root@perf-cluster-6-db2-1 ~]# echo "wcs:wcs1" | chpasswd
	
  	   su to db2inst1 and check the connection to the db with wcs1. It should work
### Copy a backup image and restore in db2 server VM

* Copy the backup image to the bucket in GCP

gsutil cp D:\Google\db_bckp\Dataset_180K_1L_916_GCP\MALL.0.db2inst1.DBPART000.20210520152916.001 gs://hclinstallfiles/db2_backups/917/perf-cluster6/
* Open an ssh session to db2 server

     `gcloud beta compute ssh --zone "us-central1-a" "perf-cluster-6-db2-1" --project "commerce-product"`
* copy the backup image from bucket to the machine

     `gsutil cp gs://hclinstallfiles/db2_backups/917/perf-cluster6/MALL.0.db2inst1.DBPART000.20210520152916.001 /mnt/disks/db/dbpath/180K`
* Restore the backup image

     `sudo su - db2inst1`
     
     `cd /mnt/disks/db/dbpath/180K`
     
     `db2 -v restore db mall to /mnt/disks/db/dbpath/database`
# GCP Cluster

     Helm charts 
		https://github02.hclpnp.com/commerce-dev/commerce-helmchart
		Replace ingressController: nginx to ingressController: gke in values.yaml

Follow this sequence: 
* prometheus
* elastic
* zk
* redis, 
* vault
* clusterrolebinding
* commerce

### Adding repos 
		helm repo add stable https://charts.helm.sh/stable 
		helm repo add bitnami https://charts.bitnami.com/bitnami
		helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
		helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
		helm repo add elastic https://helm.elastic.co
		helm repo update

### Install Prometheus
* Create the prometheus_values.yaml 

      grafana:  
         persistence:  
            type: pvc  
            enabled: true  
            storageClassName: standard  
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
                     storageClassName: standard  
                     resources:  
                        requests:  
                           # Size below should match your existing PV's size  
                           storage: 20Gi  
* Run these 2 commands 

       kubectl create namespace monitoring
       helm install prometheus prometheus-community/kube-prometheus-stack -f prometheus_values.yaml -n monitoring 

### Cluster role binding 
* Create clusterrole.yaml 

		kind: ClusterRole
		apiVersion: rbac.authorization.k8s.io/v1
		metadata:
		  name: wcs-psp
		rules:
		  - apiGroups:
			- extensions
			resources:
			- podsecuritypolicies
			resourceNames:
			- commerce-psp
			verbs:
			- use
* Run these 2 commands

      kubectl create clusterrolebinding cluster-admin-binding --clusterrole cluster-admin --user <userid@hcl.com>
      kubectl create -f clusterrole.yaml
### Installing zookeeper  
Create the namespace and install zookeeper  

      kubectl create namespace zookeeper  
      helm install zookeeper bitnami/zookeeper -n zookeeper  
		
You'll get an output with these information  

      ZooKeeper can be accessed via port 2181 on the following DNS name from within your cluster:
           zookeeper.zookeeper.svc.cluster.local
      To connect to your ZooKeeper server run the following commands:
      export POD_NAME=$(kubectl get pods --namespace zookeeper -l "app.kubernetes.io/name=zookeeper,app.kubernetes.io/instance=zookeeper,app.kubernetes.io/component=zookeeper" -o jsonpath="{.items[0].metadata.name}")
      kubectl exec -it $POD_NAME -- zkCli.sh
      To connect to your ZooKeeper server from outside the cluster execute the following commands:
            kubectl port-forward --namespace zookeeper svc/zookeeper 2181:2181 &
            zkCli.sh 127.0.0.1:2181
### Installing Elastic Search 
* Download the helm chart from https://github02.hclpnp.com/commerce-dev/commerce-helmchart
* Open the elastic yaml file and change the replica to 3
* Run the following commands 

      kubectl create namespace elastic  
      cd D:\Google\Cloud SDK\commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\sample_values  
      helm install elasticsearch elastic/elasticsearch -f elasticsearch-values.yaml -n elastic  

### Installing Redis 

    kubectl create namespace redis
    helm install redis stable/redis -f redis-values.yaml -n redis

### Install vault
* Update vault yaml and put the ip addr of the db  
* Create commerce and vault namespaces 

      kubectl create namespace vault
      kubectl create namespace commerce
	
* Run the following 

      cd D:\Google\Cloud SDK\commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-vaultconsul-helmchart\stable\hcl-commerce-vaultconsul
      helm install vault .\ -n vault -f values.yaml
	
Once vault is created, open the vault UI
* Add this key/value under qa/auth  
`searchDataQueryBaseUrl: 'https://www.demoqaauthquery-app.commerce.svc.cluster.local.:30901'`
* Add this key/value under qa/live  
`searchDataQueryBaseUrl: 'https://www.demoqaquery-app.commerce.svc.cluster.local.:30901'`
* Run this command 
  
       cd D:\Google\commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-vaultconsul-helmchart\stable\hcl-commerce-vaultconsul
       helm upgrade --install vault .\ -f values.yaml -n vault

### Deploy rbac
`cd D:\Google\commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\stable\hcl-commerce`  
open rbac.yaml and change <namespace> to commerce, then run:  
`kubectl create -f rbac.yaml `

### Deploy Commerce
Use internal ip of the db server  
Run the following commands:

    cd D:\Google\commerce\commerce-helmchart-master\commerce-helmchart-master\hcl-commerce-helmchart\stable\hcl-commerce    
    helm install demo-qa-share . -f commerce-values.yaml --set common.environmentType=share -n commerce
    helm install demo-qa-auth  . -f commerce-values.yaml --set common.environmentType=auth -n commerce
    helm install demo-qa-live  . -f commerce-values.yaml --set common.environmentType=live -n commerce
