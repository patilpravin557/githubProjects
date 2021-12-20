Liveness Probe 

 

The liveness probe is used to check the health of a container. If the container is unhealthy, Kubernetes will replace it (and kill the original) 
 

The following example behaves as follows: 

The probe itself consists is checking the tcpSocket (e.g. is Search listening) 

It runs every 10 seconds (periodSeconds) 

The liveness probe starts 10 minutes after the container is started ( initialDelaySeconds )  

A single success is required to flag the server as healthy  (alive) - (successThreshold) 

When the test fails, it will require 3 consecutive failures before the container is flagged as unhealthy (failureThreadhold) 

Each probe can timeout after 5 minutes 
(seems excessive for a tcpSocket operation) 
 

livenessProbe: 

  failureThreshold: 3 

  initialDelaySeconds: 600 

  periodSeconds: 10 

  successThreshold: 1 

  tcpSocket: 

port: 3737 

  timeoutSeconds: 300 
 

Readiness Probe 

 

Readiness and liveliness are different concepts. A POD could be healthy but still not be ready to do work, for example due to a dependency on an external system, a cache that needs to be warmed up , etc 
The readiness probe does not only concern start up. It continues running during the life of the pod (as pod could become "unready" later in their lifecycle).  Pods start  not ready until the readiness probe passes. 

 

Note that the readiness probe never kills a pod. A pod could continue to be "unready" for every. The pod is only restarted by the liveliness pod. 
For example: when loading a cache the server can be not ready, but if the process hangs, it would be the responsibility of the liveness probe to detect that and replace the unhealthy container 

 

The following example: 

The probe is done using by issuing a GET request to the server. (…/health/status) . The application 
is responsible for deciding what checks need to pass in order to return 200 OK 

The probe does not start until after 5 seconds after the pod is started (intialDelaySeconds) 

It's repeated every 5 seconds (periodSeconds) 

A single success is required to flag the server as ready - (successThreshold) 

For a ready container, the probe needs to fail 3 times before the pod can be marked unready (failureThreshold) 

 
readinessProbe: 

  failureThreshold: 3 

    httpGet: 

      httpHeaders: 

        - name: Authorization 

          value: Basic c3BpdXNlcjpwYXNzdzByZA== 

        path: /search/admin/resources/health/status?type=container 

            port: 3737 

            scheme: HTTP 

  initialDelaySeconds: 5 

  periodSeconds: 5 

  successThreshold: 1 

  timeoutSeconds: 1 
 

Notes 

Liveness and readiness probe can run concurrently  

Start readiness early, to avoid losing time if the POD becomes healthy before the probe runs 

Start liveness late, to avoid killing the pod while it is initializing  

 

 
Reference: 

https://medium.com/faun/understanding-how-kubernetes-readiness-and-liveness-probes-do-correlate-or-better-how-not-81d0ad15fd39 

 

 
