 

helm install stable/prometheus-operator -f values.yaml --name prometheus --namespace monitoring --set prometheus.ingress.enabled=true --set grafana.ingress.enabled=true --set prometheus.ingress.hosts[0]=prometheus.local --set grafana.ingress.hosts[0]=grafana.local 

NAME:   prometheus 

LAST DEPLOYED: Tue Dec 10 12:04:35 2019 

NAMESPACE: monitoring 

STATUS: DEPLOYED 

  

RESOURCES: 

==> v1/Alertmanager 

NAME                                     AGE 

prometheus-prometheus-oper-alertmanager  33s 

  

==> v1/ClusterRole 

NAME                                       AGE 

prometheus-grafana-clusterrole             33s 

prometheus-prometheus-oper-alertmanager    33s 

prometheus-prometheus-oper-operator        33s 

prometheus-prometheus-oper-operator-psp    33s 

prometheus-prometheus-oper-prometheus      33s 

prometheus-prometheus-oper-prometheus-psp  33s 

psp-prometheus-kube-state-metrics          33s 

psp-prometheus-prometheus-node-exporter    33s 

  

==> v1/ClusterRoleBinding 

NAME                                       AGE 

prometheus-grafana-clusterrolebinding      33s 

prometheus-prometheus-oper-alertmanager    33s 

prometheus-prometheus-oper-operator        33s 

prometheus-prometheus-oper-operator-psp    33s 

prometheus-prometheus-oper-prometheus      33s 

prometheus-prometheus-oper-prometheus-psp  33s 

psp-prometheus-kube-state-metrics          33s 

psp-prometheus-prometheus-node-exporter    33s 

  

==> v1/ConfigMap 

NAME                                                          DATA  AGE 

prometheus-grafana                                            1     33s 

prometheus-grafana-config-dashboards                          1     33s 

prometheus-grafana-test                                       1     33s 

prometheus-prometheus-oper-apiserver                          1     33s 

prometheus-prometheus-oper-cluster-total                      1     33s 

prometheus-prometheus-oper-controller-manager                 1     33s 

prometheus-prometheus-oper-etcd                               1     33s 

prometheus-prometheus-oper-grafana-datasource                 1     33s 

prometheus-prometheus-oper-k8s-coredns                        1     33s 

prometheus-prometheus-oper-k8s-resources-cluster              1     33s 

prometheus-prometheus-oper-k8s-resources-namespace            1     33s 

prometheus-prometheus-oper-k8s-resources-node                 1     33s 

prometheus-prometheus-oper-k8s-resources-pod                  1     33s 

prometheus-prometheus-oper-k8s-resources-workload             1     33s 

prometheus-prometheus-oper-k8s-resources-workloads-namespace  1     33s 

prometheus-prometheus-oper-kubelet                            1     33s 

prometheus-prometheus-oper-namespace-by-pod                   1     33s 

prometheus-prometheus-oper-namespace-by-workload              1     33s 

prometheus-prometheus-oper-node-cluster-rsrc-use              1     33s 

prometheus-prometheus-oper-node-rsrc-use                      1     33s 

prometheus-prometheus-oper-nodes                              1     33s 

prometheus-prometheus-oper-persistentvolumesusage             1     33s 

prometheus-prometheus-oper-pod-total                          1     33s 

prometheus-prometheus-oper-pods                               1     33s 

prometheus-prometheus-oper-prometheus                         1     33s 

prometheus-prometheus-oper-proxy                              1     33s 

prometheus-prometheus-oper-scheduler                          1     33s 

prometheus-prometheus-oper-statefulset                        1     33s 

prometheus-prometheus-oper-workload-total                     1     33s 

  

==> v1/DaemonSet 

NAME                                 DESIRED  CURRENT  READY  UP-TO-DATE  AVAILABLE  NODE SELECTOR  AGE 

prometheus-prometheus-node-exporter  4        4        4      4           4          <none>         33s 

  

==> v1/Deployment 

NAME                                 READY  UP-TO-DATE  AVAILABLE  AGE 

prometheus-grafana                   1/1    1           1          33s 

prometheus-kube-state-metrics        1/1    1           1          33s 

prometheus-prometheus-oper-operator  1/1    1           1          33s 

  

==> v1/Pod(related) 

NAME                                                  READY  STATUS   RESTARTS  AGE 

prometheus-grafana-5cc7d57bfd-c49zg                   2/2    Running  0         33s 

prometheus-kube-state-metrics-67b765f8b8-m7lvh        1/1    Running  0         33s 

prometheus-prometheus-node-exporter-dqnqx             1/1    Running  0         33s 

prometheus-prometheus-node-exporter-mqndr             1/1    Running  0         33s 

prometheus-prometheus-node-exporter-qwpzn             1/1    Running  0         33s 

prometheus-prometheus-node-exporter-rp7gz             1/1    Running  0         33s 

prometheus-prometheus-oper-operator-5c746656c5-692z7  2/2    Running  0         33s 

  

==> v1/Prometheus 

NAME                                   AGE 

prometheus-prometheus-oper-prometheus  33s 

  

==> v1/PrometheusRule 

NAME                                                             AGE 

prometheus-prometheus-oper-alertmanager.rules                    32s 

prometheus-prometheus-oper-etcd                                  32s 

prometheus-prometheus-oper-general.rules                         32s 

prometheus-prometheus-oper-k8s.rules                             32s 

prometheus-prometheus-oper-kube-apiserver.rules                  32s 

prometheus-prometheus-oper-kube-prometheus-node-recording.rules  32s 

prometheus-prometheus-oper-kube-scheduler.rules                  32s 

prometheus-prometheus-oper-kubernetes-absent                     32s 

prometheus-prometheus-oper-kubernetes-apps                       32s 

prometheus-prometheus-oper-kubernetes-resources                  32s 

prometheus-prometheus-oper-kubernetes-storage                    32s 

prometheus-prometheus-oper-kubernetes-system                     32s 

prometheus-prometheus-oper-kubernetes-system-apiserver           32s 

prometheus-prometheus-oper-kubernetes-system-controller-manager  32s 

prometheus-prometheus-oper-kubernetes-system-kubelet             32s 

prometheus-prometheus-oper-kubernetes-system-scheduler           32s 

prometheus-prometheus-oper-node-exporter                         32s 

prometheus-prometheus-oper-node-exporter.rules                   32s 

prometheus-prometheus-oper-node-network                          32s 

prometheus-prometheus-oper-node-time                             32s 

prometheus-prometheus-oper-node.rules                            32s 

prometheus-prometheus-oper-prometheus                            32s 

prometheus-prometheus-oper-prometheus-operator                   32s 

  

==> v1/Role 

NAME                     AGE 

prometheus-grafana-test  33s 

  

==> v1/RoleBinding 

NAME                     AGE 

prometheus-grafana-test  33s 

  

==> v1/Secret 

NAME                                                  TYPE    DATA  AGE 

alertmanager-prometheus-prometheus-oper-alertmanager  Opaque  1     33s 

prometheus-grafana                                    Opaque  3     33s 

  

==> v1/Service 

NAME                                                TYPE       CLUSTER-IP      EXTERNAL-IP  PORT(S)           AGE 

prometheus-grafana                                  ClusterIP  10.109.235.74   <none>       80/TCP            33s 

prometheus-kube-state-metrics                       ClusterIP  10.111.20.150   <none>       8080/TCP          33s 

prometheus-prometheus-node-exporter                 ClusterIP  10.105.176.188  <none>       9100/TCP          33s 

prometheus-prometheus-oper-alertmanager             ClusterIP  10.109.243.73   <none>       9093/TCP          33s 

prometheus-prometheus-oper-coredns                  ClusterIP  None            <none>       9153/TCP          33s 

prometheus-prometheus-oper-kube-controller-manager  ClusterIP  None            <none>       10252/TCP         33s 

prometheus-prometheus-oper-kube-etcd                ClusterIP  None            <none>       2379/TCP          33s 

prometheus-prometheus-oper-kube-proxy               ClusterIP  None            <none>       10249/TCP         33s 

prometheus-prometheus-oper-kube-scheduler           ClusterIP  None            <none>       10251/TCP         33s 

prometheus-prometheus-oper-operator                 ClusterIP  10.108.23.220   <none>       8080/TCP,443/TCP  33s 

prometheus-prometheus-oper-prometheus               ClusterIP  10.110.1.107    <none>       9090/TCP          33s 

  

==> v1/ServiceAccount 

NAME                                     SECRETS  AGE 

prometheus-grafana                       1        33s 

prometheus-grafana-test                  1        33s 

prometheus-kube-state-metrics            1        33s 

prometheus-prometheus-node-exporter      1        33s 

prometheus-prometheus-oper-alertmanager  1        33s 

prometheus-prometheus-oper-operator      1        33s 

prometheus-prometheus-oper-prometheus    1        33s 

  

==> v1/ServiceMonitor 

NAME                                                AGE 

prometheus-prometheus-oper-alertmanager             32s 

prometheus-prometheus-oper-apiserver                32s 

prometheus-prometheus-oper-coredns                  32s 

prometheus-prometheus-oper-grafana                  32s 

prometheus-prometheus-oper-kube-controller-manager  32s 

prometheus-prometheus-oper-kube-etcd                32s 

prometheus-prometheus-oper-kube-proxy               32s 

prometheus-prometheus-oper-kube-scheduler           32s 

prometheus-prometheus-oper-kube-state-metrics       32s 

prometheus-prometheus-oper-kubelet                  32s 

prometheus-prometheus-oper-node-exporter            32s 

prometheus-prometheus-oper-operator                 32s 

prometheus-prometheus-oper-prometheus               32s 

  

==> v1beta1/ClusterRole 

NAME                           AGE 

prometheus-kube-state-metrics  33s 

  

==> v1beta1/ClusterRoleBinding 

NAME                           AGE 

prometheus-kube-state-metrics  33s 

  

==> v1beta1/Ingress 

NAME                                   HOSTS             ADDRESS  PORTS  AGE 

prometheus-grafana                     grafana.local     80       33s 

prometheus-prometheus-oper-prometheus  prometheus.local  80       33s 

  

==> v1beta1/MutatingWebhookConfiguration 

NAME                                  AGE 

prometheus-prometheus-oper-admission  33s 

  

==> v1beta1/PodSecurityPolicy 

NAME                                     PRIV   CAPS      SELINUX           RUNASUSER  FSGROUP    SUPGROUP  READONLYROOTFS  VOLUMES 

prometheus-grafana                       false  RunAsAny  RunAsAny          RunAsAny   RunAsAny   false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim 

prometheus-grafana-test                  false  RunAsAny  RunAsAny          RunAsAny   RunAsAny   false     configMap,downwardAPI,emptyDir,projected,secret 

prometheus-kube-state-metrics            false  RunAsAny  MustRunAsNonRoot  MustRunAs  MustRunAs  false     secret 

prometheus-prometheus-node-exporter      false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim,hostPath 

prometheus-prometheus-oper-alertmanager  false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim 

prometheus-prometheus-oper-operator      false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim 

prometheus-prometheus-oper-prometheus    false  RunAsAny  RunAsAny          MustRunAs  MustRunAs  false     configMap,emptyDir,projected,secret,downwardAPI,persistentVolumeClaim 

  

==> v1beta1/Role 

NAME                AGE 

prometheus-grafana  33s 

  

==> v1beta1/RoleBinding 

NAME                AGE 

prometheus-grafana  33s 

  

==> v1beta1/ValidatingWebhookConfiguration 

NAME                                  AGE 

prometheus-prometheus-oper-admission  32s 

  

  

NOTES: 

The Prometheus Operator has been installed. Check its status by running: 

  kubectl --namespace monitoring get pods -l "release=prometheus" 

  

Visit https://github.com/coreos/prometheus-operator for instructions on how 

to create & configure Alertmanager and Prometheus instances using the Operator. 
