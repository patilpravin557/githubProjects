https://stackoverflow.com/questions/28785383/how-to-disable-persistence-with-redis 

 

RDB 

 

to enable rdb persistance in redis yamal file configmap section add this 

  

save 900 1 

save 300 10 

save 60 10000 

  

to disable it 

  

save "" 




AOF 

 

Disable AOF by setting the appendonly configuration directive to no (it is the default value). like this: 

 

appendonly no 

 

After enable it 

 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ cat redis.conf | grep append 

# Enable AOF https://redis.io/topics/persistence#append-only-file 

appendonly yes 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ pwd 

/opt/bitnami/redis/etc 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$        

 

 

 

When  its disable 

 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ cat redis.conf | grep append 

# Enable AOF https://redis.io/topics/persistence#append-only-file 

appendonly no 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ redis-cli config get save 

1) "save" 

2) "" 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ 

  

 When its enable 

 

Use 'kubectl describe pod/redis-master-0 -n redisc' to see all of the containers in this pod. 

I have no name!@redis-master-0:/$ redis-cli config get save 

1) "save" 

2) "900 1 300 10 60 10000 900 1 300 10 60 10000" 

I have no name!@redis-master-0:/$ cd /opt/bitnami/redis/etc 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ cat redis.conf | grep append 

# Enable AOF https://redis.io/topics/persistence#append-only-file 

#appendonly no 

appendonly yes 

I have no name!@redis-master-0:/opt/bitnami/redis/etc$ 
