@echo on

REM 1. Image build
echo running  *** docker build -t performance/search-query-app:v9.1.8.0 . ***
docker build -t performance/search-query-app:v9.1.8.0 .

REM 2. Image Tag
echo running  *** docker tag performance/search-query-app:v9.1.8.0 us.gcr.io/performance/search-query-app:v9.1.8.0 ***
docker tag performance/search-query-app:v9.1.8.0 us.gcr.io/commerce-product/performance/raimee/search-query-app:v9.1.8.0.IBMJCEPlus

REM # 3. Image Push
echo  running  *** docker push us.gcr.io/performance/search-query-app:v9.1.8.0 ***
docker push us.gcr.io/commerce-product/performance/raimee/search-query-app:v9.1.8.0.IBMJCEPlus
