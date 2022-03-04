docker pull comlnx94.prod.hclpnp.com/bvt/9.1.7.0/ts-app:bvt-verified 

docker tag comlnx94.prod.hclpnp.com/bvt/9.1.7.0/ts-app:bvt-verified us.gcr.io/commerce-product/performance/pravin/ts-app:bvt-verified 

docker push us.gcr.io/commerce-product/performance/pravin/ts-app:bvt-verified 



[root@perf-cluster-2-db2 tmp]# docker pull us.gcr.io/commerce-product/performance/pravin/ts-utils:v9-latest 

Trying to pull repository us.gcr.io/commerce-product/performance/pravin/ts-utils ... 

v9-latest: Pulling from us.gcr.io/commerce-product/performance/pravin/ts-utils 

2d473b07cdd5: Pull complete 

e8869b8c5615: Pull complete 

3e807fb51053: Pull complete 

3e5944903993: Pull complete 

03378d603ef2: Pull complete 

72479be7f8da: Pull complete 

a80c6701cc7d: Pull complete 

cca71065cb9d: Pull complete 

ab479133308d: Pull complete 

1fcde7fe13b0: Pull complete 

ec594c887b2f: Pull complete 

97ad5c3fc8b4: Pull complete 

1f4c5f575d24: Pull complete 

Digest: sha256:cf5924ea314070a4de8a44e537963b64ff7912db237119ef7da303442eae12cc 

Status: Downloaded newer image for us.gcr.io/commerce-product/performance/pravin/ts-utils:v9-latest 

[root@perf-cluster-2-db2 tmp]# 

  

 
