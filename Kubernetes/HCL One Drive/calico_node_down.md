Run this to ensure all calico nodes are up: 
kubectl get pods -n kube-system -o wide | grep calico 
run kubectl logs for the pod that is down: 
 
Warning  Unhealthy  17m  kubelet  Readiness probe failed: 2021-01-04 17:24:47.807 [INFO][436] confd/health.go 180: Number of node(s) with BGP peering established = 0 
calico/node is not ready: BIRD is not ready: BGP not established with 10.190.66.227,10.190.66.232 
 
 
Troubleshooting I found one node had the wrong interface. By default Calico uses the first one that it finds.To 
 
[root@COMP-4590-1 ~]# kubectl logs calico-node-l8p5c -n kube-system | grep "Using autodetected" | tail -1 
2021-01-04 18:20:34.776 [INFO][55] monitor-addresses/startup.go 756: Using autodetected IPv4 address on interface br-c6e04b432ed1: 173.17.0.1/16 
 
[root@COMP-4590-1 ~]# kubectl logs calico-node-84z6m  -n kube-system | grep "Using autodetected" | tail -1 
2021-01-04 18:20:43.320 [INFO][56] monitor-addresses/startup.go 756: Using autodetected IPv4 address on interface ens192: 10.190.66.227/23 
 
[root@COMP-4590-1 ~]# kubectl logs calico-node-wnm8x -n kube-system | grep "Using autodetected" | tail -1 
2021-01-04 18:20:57.519 [INFO][61] monitor-addresses/startup.go 756: Using autodetected IPv4 address on interface ens192: 10.190.66.232/23 
 
To fix, edit the DS and add IP_AUTODETECTION_METHOD 
 
kubectl edit -n kube-system ds calico-node 
 
# Specify interface 
            - name: IP_AUTODETECTION_METHOD 
              value: "interface=ens192" 
