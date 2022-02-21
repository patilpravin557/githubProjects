## Redis Copy

kubectl cp redis-master-0:/data/dump.rdb /tmp/dump.rdb -n redis -c redis 

tar: Removing leading `/' from member names 

## Create rdb file for redis 

root@COMP-4590-1 ~]# kubectl exec -it redis-master-0 -n redis bash 

kubectl exec [POD] [COMMAND] is DEPRECATED and will be removed in a future version. Use kubectl exec [POD] -- [COMMAND] instead. 

Defaulting container name to redis. 

Use 'kubectl describe pod/redis-master-0 -n redis' to see all of the containers in this pod. 

I have no name!@redis-master-0:/$ redis-cli save 

OK 

I have no name!@redis-master-0:/bitnami/redis/data$ cd ~ 

I have no name!@redis-master-0:/$ ls 

bin  bitnami  boot  data  dev  entrypoint.sh  etc  health  home  lib  lib64  media  mnt  opt  proc  root  run  run.sh  sbin  srv  sys  tmp  usr  var 

I have no name!@redis-master-0:/$ cd data/ 

I have no name!@redis-master-0:/data$ ls 

dump.rdb 

## Stage prop direct command
kubectl exec -it -n commerce utility-app -- /opt/WebSphere/CommerceServer90/bin/stagingprop.sh -scope _all_ -dbtype DB2 -sourcedb demoqaauthdb.commerce.svc.cluster.local:50000/mall -sourcedb_user wcs -sourcedb_passwd wcs1 -destdb demoqalivedb.commerce.svc.cluster.local:50000/mall -destdb_user wcs -destdb_passwd wcs1 

/root/setup 

./push_to_live.sh 

 
