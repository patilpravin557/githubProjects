Install vault 

 

[root@com-kube-node1 stable]# pwd 

/root/solr_917/commerce-helmchart-master/commerce-helmchart-master/hcl-commerce-vaultconsul-helmchart/stable 

[root@com-kube-node1 stable]# helm install vault ./hcl-commerce-vaultconsul/ -f hcl-commerce-vaultconsul/solr_values.yaml -n vault 

 

 

unstall redis 

 

[root@com-kube-node1 ~]# helm delete redis -n redis --no-hooks 

release "redis" uninstalled 

[root@com-kube-node1 ~]# 

 

Create pv and pvc delete old ones 

 

[root@com-kube-node1 pvc]# kubectl create -f pv_redis.yaml -n redis 

persistentvolume/redis-solr-pv created 

 

[root@com-kube-node1 pvc]# kubectl create -f pvc_redis.yaml -n redis 

persistentvolumeclaim/redis-data-redis-master-0 created 

 

Install cluster redis 

[root@com-kube-node1 ~]# pwd 

/root 

helm install redis bitnami/redis-cluster -f redis_cluster_values.yaml -n redis 

 

Install single redis 

 

[root@com-kube-node1 ~]# pwd 

/root 

helm install redis stable/redis -f redis_values_raimee.yaml -n redis (use tins installation file under root) 

[root@com-kube-node1 ~]# helm install redis stable/redis -f ./redis_values.yaml -n redis 

  

Install commerce 

 

575  cd solr_917/ 

  576  ll 

  577  cd commerce-helmchart-master/ 

  578  ll 

  579  cd commerce-helmchart-master/ 

  580  ll 

  581  cd hcl-commerce-helmchart/ 

  582  ll 

  583  cd stable/ 

  584  ll 

  585  cd hcl-commerce/ 

  586  ll 

  587    588  clear 

 

[root@com-kube-node1 hcl-commerce]# pwd 

/root/solr_917/commerce-helmchart-master/commerce-helmchart-master/hcl-commerce-helmchart/stable/hcl-commerce 

 

 

[root@com-kube-node1 hcl-commerce]# helm delete demo-qa-auth --no-hooks 

W0827 07:54:37.750861   21866 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress 

W0827 07:54:37.751115   21866 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress 

release "demo-qa-auth" uninstalled 

[root@com-kube-node1 hcl-commerce]# helm delete demo-qa-live --no-hooks 

W0827 07:54:47.623301   22322 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress 

W0827 07:54:47.623597   22322 warnings.go:67] networking.k8s.io/v1beta1 Ingress is deprecated in v1.19+, unavailable in v1.22+; use networking.k8s.io/v1 Ingress 

release "demo-qa-live" uninstalled 

[root@com-kube-node1 hcl-commerce]# 

 

  

  helm install demo-qa-auth . -f solr_values_918.yaml --set common.environmentType=auth -n commerce 

 

helm ugrade demo-qa-auth . -f solr_values_918.yaml --set common.environmentType=auth -n commerce 

   

  helm install demo-qa-live . -f solr_values_918.yaml --set common.environmentType=live -n commerce 

  

   

 

 

 

 

https://github02.hclpnp.com/commerce-dev/commerce-helmchart 

 

 

[root@com-kube-node1 pvc]# pwd 

/root/solr_917/pvc 

[root@com-kube-node1 pvc]# ll 

total 44 

-rw-r--r-- 1 root root 224 May  7 10:01 1 

drwxr-xr-x 7 root root 165 May  7 11:55 kubernetes-pv 

-rw-r--r-- 1 root root 312 May  7 09:59 pv_authtsdb.yaml 

-rw-r--r-- 1 root root 224 May  7 10:01 pvc_authtsdb.yaml 

-rw-r--r-- 1 root root 226 May  3 13:11 pvc_claim_searchAppMaster.yaml 

-rw-r--r-- 1 root root 230 May  3 13:12 pvc_claim_searchAppRepeater.yaml 

-rw-r--r-- 1 root root 224 May  7 11:59 pvc_livetsdb.yaml 

-rw-r--r-- 1 root root 214 May  7 11:19 pvc_redis.yaml 

-rw-r--r-- 1 root root 312 May  7 11:58 pv_livetsdb.yaml 

-rw-r--r-- 1 root root 285 May  7 11:20 pv_redis.yaml 

-rw-r--r-- 1 root root 319 May  3 13:11 pv_searchAppMaster.yaml 

-rw-r--r-- 1 root root 325 May  3 13:11 pv_searchAppRepeater.yaml 

[root@com-kube-node1 pvc]# 

 

 

Create pv and pvc for master and repeater 

 

 

 

apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: svtcommerce-search-master-pvc 

  namespace: commerce 

  labels: 

    type: local 

spec: 

  storageClassName: local-storage-serach-master 

  capacity: 

    storage: 10Gi 

  accessModes: 

    - ReadWriteOnce 

  hostPath: 

    path: "/kubernetes-pv/local-storage-serach-master" 

------------------------------ 

apiVersion: v1 

kind: PersistentVolumeClaim 

metadata: 

  name: svtcommerce-search-master-pvc-claim 

spec: 

  storageClassName: local-storage-serach-master 

  accessModes: 

    - ReadWriteOnce 

  resources: 

    requests: 

      storage: 3Gi 

************************************************************ 

  

apiVersion: v1 

kind: PersistentVolume 

metadata: 

  name: svtcommerce-search-repeater-pvc 

  namespace: commerce 

  labels: 

    type: local 

spec: 

  storageClassName: local-storage-search-repeater 

  capacity: 

    storage: 10Gi 

  accessModes: 

    - ReadWriteOnce 

  hostPath: 

    path: "/kubernetes-pv/local-storage-search-repeater" 

  

apiVersion: v1 

kind: PersistentVolumeClaim 

metadata: 

  name: svtcommerce-search-repeater-pvc-claim 

spec: 

  storageClassName: local-storage-search-repeater 

  accessModes: 

    - ReadWriteOnce 

  resources: 

    requests: 

      storage: 3Gi 

 

 

NAME: demo-qa-auth 

LAST DEPLOYED: Mon May  3 11:35:17 2021 

NAMESPACE: commerce 

STATUS: deployed 

REVISION: 1 

NOTES: 

Chart: hcl-commerce-1.1.2 

  

HCL Commerce V9 demo-qa-auth release startup will take average 10-15 minutes with sequence. 

  

Access Environment: 

  

1. Check ingress server IP address. 

kubectl get ingress -n <Namespace> 

  

  

2. Create the ingress server IP and hostname mapping on your server by editing the  /etc/hosts file. 

  

10.190.67.32 tsapp.demoqaauth.pravin.solr.svt.com 

10.190.67.32 cmc.demoqaauth.pravin.solr.svt.com 

10.190.67.32 accelerator.demoqaauth.pravin.solr.svt.com 

10.190.67.32 admin.demoqaauth.pravin.solr.svt.com 

10.190.67.32 org.demoqaauth.pravin.solr.svt.com 

10.190.67.32 store.demoqaauth.pravin.solr.svt.com 

10.190.67.32 search.demoqaauth.pravin.solr.svt.com 

  

3. Access the environment with following URLs: 

Aurora Store Front: 

https://store.demoqaauth.pravin.solr.svt.com/wcs/shop/en/auroraesite 

  

Management Center: 

https://cmc.demoqaauth.pravin.solr.svt.com/lobtools/cmc/ManagementCenter 

  

Organization Admin Console: 

https://org.demoqaauth.pravin.solr.svt.com/webapp/wcs/orgadmin/servlet/ToolsLogon?XMLFile=buyerconsole.BuyAdminConsoleLogon 

  

Accelerator: 

https://accelerator.demoqaauth.pravin.solr.svt.com/webapp/wcs/tools/servlet/ToolsLogon?XMLFile=common.mcLogon 

  

Commerce Admin Console: 

https://admin.demoqaauth.pravin.solr.svt.com/webapp/wcs/admin/servlet/ToolsLogon?XMLFile=adminconsole.AdminConsoleLogon 

  

  

  

  

Access Environment: 

  

1. Check ingress server IP address. 

kubectl get ingress -n <Namespace> 

  

  

2. Create the ingress server IP and hostname mapping on your server by editing the  /etc/hosts file. 

  

10.190.67.32 tsapp.demoqalive.pravin.solr.svt.com 

10.190.67.32 cmc.demoqalive.pravin.solr.svt.com 

10.190.67.32 accelerator.demoqalive.pravin.solr.svt.com 

10.190.67.32 admin.demoqalive.pravin.solr.svt.com 

10.190.67.32 org.demoqalive.pravin.solr.svt.com 

10.190.67.32 store.demoqalive.pravin.solr.svt.com 

10.190.67.32 searchrepeater.demoqalive.pravin.solr.svt.com 

  

3. Access the environment with following URLs: 

Aurora Store Front: 

https://store.demoqalive.pravin.solr.svt.com/wcs/shop/en/auroraesite 

  

Management Center: 

https://cmc.demoqalive.pravin.solr.svt.com/lobtools/cmc/ManagementCenter 

  

Organization Admin Console: 

https://org.demoqalive.pravin.solr.svt.com/webapp/wcs/orgadmin/servlet/ToolsLogon?XMLFile=buyerconsole.BuyAdminConsoleLogon 

  

Accelerator: 

https://accelerator.demoqalive.pravin.solr.svt.com/webapp/wcs/tools/servlet/ToolsLogon?XMLFile=common.mcLogon 

  

Commerce Admin Console: 

https://admin.demoqalive.pravin.solr.svt.com/webapp/wcs/admin/servlet/ToolsLogon?XMLFile=adminconsole.AdminConsoleLogon 

[root@com-kube-node1 hcl-commerce]# 

 

 

Indexing in auth and live  

 

auth 

 

[root@com-kube-node1 ~]# curl -k -sS -u spiuser:passw0rd -X POST https://tsapp.demoqaauth.pravin.solr.svt.com/wcs/resources/admin/index/dataImport/build?masterCatalogId=10001 

{"jobStatusId":"1001"}[root@com-kube-node1 ~]# 

 

 [root@com-kube-node1 pvc]# curl -k -sS -u spiuser:passw0rd -X GET https://tsapp.demoqaauth.pravin.solr.svt.com/wcs/resources/admin/index/dataImport/status?jobStatusId=1001 

{"status":{"finishTime":"2021-05-07 16:46:50.69383","lastUpdate":"2021-05-07 16:46:50.69383","progress":"100%","jobStatusId":"1001","startTime":"2021-05-07 16:46:11.145277","message":"Full indexing job started for masterCatalogId:10,001.\nIndexing job finished successfully for masterCatalogId:10001.\n","jobType":"SearchIndex","properties":"[masterCatalogId=10001]","status":"0"}}[root@com-kube-node1 pvc]# 

 

 

Live 

 

[root@com-kube-node1 ~]# curl -k -sS -u spiuser:passw0rd -X POST https://searchrepeater.demoqalive.pravin.solr.svt.com/search/admin/resources/index/replicate?indexId=10001 

{"jobStatusId":1000001}[root@com-kube-node1 ~]# 

 

 

[root@com-kube-node1 ~]# curl -k -sS -u spiuser:passw0rd -X GET https://searchrepeater.demoqalive.pravin.solr.svt.com/search/admin/resources/te/status?jobStatusId=1000001 

{"status":0}[root@com-kube-node1 ~]# 

 

Db side update if price not available 

 

[db2inst1@demoqaauthdb-548948cbb7-jpz5h ~]$ db2 connect to mall 

  

   Database Connection Information 

  

Database server        = DB2/LINUXX8664 11.5.0.0 

SQL authorization ID   = DB2INST1 

Local database alias   = MALL 

  

[db2inst1@demoqaauthdb-548948cbb7-jpz5h ~]$ db2 "update wcs.storeconf set VALUE='0' where NAME='wc.search.priceMode.compatiblePriceIndex'" 

DB20000I  The SQL command completed successfully. 

[db2inst1@demoqaauthdb-548948cbb7-jpz5h ~]$ 
