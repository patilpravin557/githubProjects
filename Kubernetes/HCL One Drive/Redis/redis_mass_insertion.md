parallel -u ::: './curl_shell_1.sh 1' './curl_shell_2.sh 2' './curl_shell_3.sh 3' './curl_shell_4.sh 4' './curl_shell_5.sh 5' './curl_shell_6.sh 6' './curl_shell_7.sh 7' './curl_shell_8.sh 8' './curl_shell_9.sh 9' './curl_shell_10.sh 10' 

  

parallel -u ::: './curl_shell_11.sh 1' './curl_shell_12.sh 2' './curl_shell_13.sh 3' './curl_shell_14.sh 4' './curl_shell_15.sh 5' './curl_shell_16.sh 6' './curl_shell_17.sh 7' './curl_shell_18.sh 8' './curl_shell_19.sh 9' './curl_shell_20.sh 10' 

  

redis-cli info memory | grep human 

 

 

[root@com-kube-node1 tmp]# kubectl cp redis-master-0:/data/dump.rdb /tmp/dump.rdb -n redis -c redis 

tar: Removing leading `/' from member names 

 

 

 

 

kubectl cp dump.rdb redisc-redis-cluster-0:/bitnami/redis/data/dump.rdb -n redisc -c redisc-redis-cluster 

 

 

kubectl exec -n redisc redisc-redis-cluster-0 -c redisc-redis-cluster redis-cli dbsize 

 

[root@com-kube-master ~]# awk -F ',' '{print "SET " $1 " " $2}' num.csv >>redis_format1.csv 

[root@com-kube-master ~]# kubectl cp redis_format1.csv redis-master-0:/data/redis_format1.csv -n redis -c redis 

[root@com-kube-master ~]# kc exec -it -n redis redis-master-0 -- bash 

Defaulting container name to redis. 

Use 'kubectl describe pod/redis-master-0 -n redis' to see all of the containers in this pod. 

I have no name!@redis-master-0:/$ cd data/ 

I have no name!@redis-master-0:/data$ ls 

redis_format.csv  redis_format1.csv 

  

I have no name!@redis-master-0:/data$ cat redis_format1.csv| redis-cli --pipe 

All data transferred. Waiting for the last reply... 

Last reply received from server. 

errors: 0, replies: 1000001 

I have no name!@redis-master-0:/data$ 

  

I have no name!@redis-master-0:/data$ redis-cli dbsize 

(integer) 1000028 
