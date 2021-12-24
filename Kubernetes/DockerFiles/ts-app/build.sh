@echo off

REM 1. Image build
echo running  *** docker build -t performance/ts-app:v9.1.7.0 . ***
docker build -t performance/ts-app:v9.1.7.0 .

REM 2. Image Tag
echo running  *** docker tag performance/ts-app:v9.1.7.0 us.gcr.io/commerce-product/performance/ts-app:v9.1.7.0 ***
docker tag performance/ts-app:v9.1.7.0 us.gcr.io/commerce-product/performance/raimee/ts-app:v9.1.7.0.IBMJCEPlus

REM # 3. Image Push
echo  running  *** docker push us.gcr.io/commerce-product/performance/ts-app:v9.1.7.0 ***
docker push us.gcr.io/commerce-product/performance/raimee/ts-app:v9.1.7.0.IBMJCEPlus
