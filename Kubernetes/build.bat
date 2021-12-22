@echo off

REM 1. Image build
echo running  *** docker build -t v9hclcache/search-registry-app:v9-latest . ***
docker build -t v9hclcache/search-registry-app:v9-latest .

REM 2. Image Tag
echo running  *** docker tag v9hclcache/search-registry-app:v9-latest comlnx94.prod.hclpnp.com/v9hclcache/search-registry-app:v9-latest ***
docker tag v9hclcache/search-registry-app:v9-latest comlnx94.prod.hclpnp.com/v9hclcache/search-registry-app:v9-latest

REM # 3. Image Push
echo  running  *** docker push comlnx94.prod.hclpnp.com/v9hclcache/search-registry-app:v9-latest ***
docker push comlnx94.prod.hclpnp.com/v9hclcache/search-registry-app:v9-latest