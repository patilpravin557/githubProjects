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


kubectl exec -it -n redisc redisc-redis-cluster-0 -c redisc-redis-cluster -- redis-cli cluster meet 10.47.128.3 6379          

 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster info;done 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster nodes;done 

 

 

for i in 0 1 2;do echo "member $i:" && kubectl exec -it -n redisc redisc-redis-cluster-$i -c redisc-redis-cluster -- redis-cli cluster forget 890a02101076b9ece0dc184843ce869495f9db8e 

 

kubectl get all -n redisc -owide 

 

kubectl get all -n redisc 

 

kubectl get deployments -A 

 

kubectl exec -it -n redisc redisc-redis-cluster-1 -c redisc-redis-cluster -- bash  



## useful commands

kubectl scale statefulset redis-master -n redis --replicas=0 

kubectl scale statefulset redis-master -n redis --replicas=1 

 

 

***********Keys*  ********** 

set name abc 

get name 

Keys * 

del name 

flushall---> delete all the values 

setex --> set value with expiry of key in sec 

setex name 10 max 

ttl name (time to live) 

setnx check the key is availble or not  if availble the retun 0 and dot overwrite 

lenght of value store inside the key--> strlen name2 

  

***set multiple values************************ 

mset num1 50 num2 60 

****set the key for milisecond************************* 

psetex key milliseconds 

*****increment and decrement************************************* 

decr num1 

incr num1 

****** increment/ decr value by 5**************************** 

incrby num1 5 

decrby num1 30 

*****append************************** 

set mykey hello 

append mykey " world" 

*****Hashe**************************** 

these are key field value pairs 

hmset stu-1 name max age 15 class 8 

toget the values :-hget stu-1 name 

To get the all values of student 1 

hgetall stu-1---> gives fileds and value both 

hkeys stu1 ---> give only filed name 

hvals stu-1-----> give only values of the fileds 

hexists stu-1 surname (returns 0 if not exists else 1) 

delete value 

hdel stu-1 class 

hsetnx stu-1 name tom...returns 0 since name filed exists 

hincrby stu-1 age 2 ---->age increment by 2 

hlen stu-1 -----> lengh of hash i.e number of fields 

hmget stu-1 name ---->perticular value of filed 

hmget stu-1 name age 

**********redis Lists********************* 

are simply list of strings sorted by insertion order 

data can be inserted from top as well as bottom 

create redis list 

lpush num 1 2 3 4 ----> Push values from top 

lrange num 0 10 

output:- 

4 

3 

2 

1 

lpop num------>remove value from top 

from bottom 

rpush num 5 

lrange num 0 10 

4 

3 

2 

1 

5 

rpop num----->remove value from bottom 

llen---lengh of list 

llen num 

lindex num 3 

lset num 0  5 ---->insert the value at the 0th index value 5 

it will rplace the 4 value to 5 

if we do not know the lengh of the list 

lrange num 0 -1 

left push if key exist 

lpushx num 1 

lpushx sub 1 2 3 ---->returns 0 since key does not exists 

linsert num before pivot value 

linsert num before 2 55 

lrange num 0 -1 

linsert num after 5 4 

*********Monitor all commands********************* 

Need to open two terminals 

redis-cli monitor 

------- show the commands executed with the time stamp 

*****************sets****************** 

Unordered collection of only unique strings 

create set---> sadd myset1 1 2 3 4 

view members of set---> smembers myset1  

sadd myset1 3 ---> returns 0 since 3 is alredy present 

scard myset1--->how many members in set 

sdiff myset1 myset2--->differnce mens value which are in set1 but not in set2 

store difference into new set---> sdiffstore myset3 myset1 myset2 

union of sets---> sunion myset1 myset2 

storing the union--->sunionstore myset4 myset1 myset2 

remove member from set--> srem myset4  9 

remove random value from set--> spop myset4 1---remove only1 

sinter myset1 myset2---> intersection i.e. values preset on both sets 

sinterstore myset3 myset1 myset2---> store into myset3 

smove myset1 myset2 1 ---> move value 1 from set1 to set2 

***********sorted set************************* 

smilar to sets but members are sorted with score 

zadd myset1 1 a 2 b 3 c 5 d 

get the member---> zrange myset1 0 -1 

a 

b 

c 

d 

zcount myset1 1 3--->number of values in between scores 

3 

zrem myset b--->delete the member 

zrank myset1 d--->index of member 

3 

zrevrank myset1 d--->index of member with reverse orde 

0 

zscore myset1 a ---> score value of member 

1 

zrangebyscore myset1 1 2--->min and max value 

*****************redis Publish-subscribe******************** 

Subscribe redis 

publish redis "Hello World" 

psubscribe r* 

*************Latency doctor******************************** 

CONFIG SET latency-monitor-threshold 1000---enable latency 

latency doctor----> show the spikes observed 

******** slowlog******************************************* 

127.0.0.1:6379> slowlog get 10 

) 1) (integer) 0 

  2) (integer) 1589379329 

  3) (integer) 16109 

  4) 1) "COMMAND" 

  5) "127.0.0.1:52754" 

  6) "" 

slowlog len 

slowlog reset 

 

 
