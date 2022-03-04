[root@perf-cluster-2-db2 ~]# firewall-cmd --state 

running 

[root@perf-cluster-2-db2 ~]# systemctl stop firewalld 

[root@perf-cluster-2-db2 ~]# syatemctl disable firewalld 

-bash: syatemctl: command not found 

[root@perf-cluster-2-db2 ~]# systemctl disable firewalld 

Removed symlink /etc/systemd/system/multi-user.target.wants/firewalld.service. 

Removed symlink /etc/systemd/system/dbus-org.fedoraproject.FirewallD1.service. 

[root@perf-cluster-2-db2 ~]# systemctl mask --now firewalld 

Created symlink from /etc/systemd/system/firewalld.service to /dev/null. 

[root@perf-cluster-2-db2 ~]# firewall-cmd --state 

not running 

[root@perf-cluster-2-db2 ~]# 

 
