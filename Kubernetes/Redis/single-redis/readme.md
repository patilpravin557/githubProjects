
# Single Instance Redis with Helm

https://github.com/bitnami/charts/tree/master/bitnami/redis

```
kubectl create ns redis
helm install redis bitnami/redis -f ./values.yaml -n redis
```

Going into container:
```
kubectl exec -it -n redis redis-master-0 -c redis -- bash
```

Reading logs:
```
kubectl logs -n redis redis-master-0 -c redis
```

Remove Release:
```
helm delete redis --namespace redis
```
