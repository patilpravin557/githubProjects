@echo off

REM 1. Image build
echo running  *** docker build -t performance/cache-app:v9.1.6.0 . ***
docker build -t performance/cache-app:v9.1.6.0 .

REM 2. Image Tag
echo running  *** docker tag performance/cache-app:v9.1.6.0 us.gcr.io/commerce-product/performance/cache-app:v9.1.6.0 ***
docker tag performance/cache-app:v9.1.6.0 us.gcr.io/commerce-product/performance/cache-app:v9.1.6.0

REM # 3. Image Push
echo  running  *** docker push us.gcr.io/commerce-product/performance/cache-app:v9.1.6.0 ***
docker push us.gcr.io/commerce-product/performance/cache-app:v9.1.6.0
