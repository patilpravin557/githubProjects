# Expiry Test 

kubectl exec -it -n redis redis-master-0 -c redis -- bash 
 

# EXPIRE key seconds  
# 1 year = 31536000 seconds 
 

redis-cli --scan --pattern "{cache-demoqalive-services/loadtest/cache/size_xxs_1}-data-*" | xargs -I {} redis-cli expire {} 31536000 
 

# find some keys to check ... 
redis-cli --scan --pattern "{cache-demoqalive-services/loadtest/cache/size_xxs_1}-data-*000001*" 
# pick keys randomly and check TTL 
I have no name!@redis-master-0:/$ redis-cli TTL '{cache-demoqalive-services/loadtest/cache/size_xxs_1}-data-cache_id_0000019' 
(integer) 31535840 

 

 
