docker pull comlnx94.prod.hclpnp.com/redisapp/bitnami-redis:latest 

 
docker run --name bitnami-redis -e ALLOW_EMPTY_PASSWORD=yes -p 6379:6379 -d comlnx94.prod.hclpnp.com/redisapp/bitnami-redis:latest /run.sh --maxmemory 100mb --maxmemory-policy volatile-lru 

 
