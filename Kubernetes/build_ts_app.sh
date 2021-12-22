@echo off

REM 1. Image build
echo running  *** docker build -t performance/pravin/ts-app:v9-20210403-0911 . ***
docker build -t performance/pravin/ts-app:v9-20210403-0911 .

REM 2. Image Tag
echo running  *** docker tag performance/pravin/ts-app:v9-20210403-0911 comlnx94.prod.hclpnp.com/performance/pravin/ts-app:v9-20210403-0911 ***
docker tag performance/pravin/ts-app:v9-20210403-0911 comlnx94.prod.hclpnp.com/performance/pravin/ts-app:v9-20210403-0911

REM # 3. Image Push
echo  running  *** docker push comlnx94.prod.hclpnp.com/performance/pravin/ts-app:v9-20210403-0911 ***
docker push comlnx94.prod.hclpnp.com/performance/pravin/ts-app:v9-20210403-0911