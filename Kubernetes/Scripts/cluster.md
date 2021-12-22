# Cluster

**Provision the VM's using the k8s-ready template - US-COMMERCE-RHEL7-64B-K8S**

      Verify if the Machine is reimaged using the "Kubernetes" image so that kuberenetes is already insatlled. 
      It is recommended to use the image for Kubernetes rather than starting from scratch.
   
  Execute the below to update  : - 
            
            yum -y update
         
         Updated:
        containerd.io.x86_64 0:1.2.13-3.2.el7      docker-ce.x86_64 3:19.03.12-3.el7      docker-ce-cli.x86_64 1:19.03.12-3.el7      kubeadm.x86_64 0:1.18.8-0
        kubectl.x86_64 0:1.18.8-0                  kubelet.x86_64 0:1.18.8-0              kubernetes-cni.x86_64 0:0.8.6-0

      Complete!

Check Kubernetes and Docker version 

      [root@COMP-4148-1 ~]# kubectl version
      Client Version: version.Info{Major:"1", Minor:"18", GitVersion:"v1.18.8", GitCommit:"9f2892aab98fe339f3bd70e3c470144299398ace", GitTreeState:"clean", BuildDate:"2020-08-13T16:12:48Z", GoVersion:"go1.13.15", Compiler:"gc", Platform:"linux/amd64"}
      The connection to the server localhost:8080 was refused - did you specify the right host or port?
      [root@COMP-4148-1 ~]# docker version
      Client: Docker Engine - Community
       Version:           19.03.12
       API version:       1.40
       Go version:        go1.13.10
       Git commit:        48a66213fe
       Built:             Mon Jun 22 15:46:54 2020
       OS/Arch:           linux/amd64
       Experimental:      false
            

**Now you can move to Step 5 to set up cluster or follow the below Steps to Set up VM for Kuberenetes** 
 

**Step 1 -Verify the below on the Machines**

      |  Verify Redhat linux 7.7 installed   | hostnamectl  |
      | --- | --- |
      | Verify CPU cores min required is 2  | lscpu |
      | Verify Available Memory min 12 GB  | Free -m  |
      | Verify Disk Space (100 GB)  | fdisk -l | grep Disk  |
      | Verify SELinux Disabled   | sestatus  |
      | Verify Firewall not running  | firewall-cmd --state  |

**Step 2-Install Docker**

   - yum install -y yum-utils

   - yum-config-manager \
    --add-repo \
    [https://download.docker.com/linux/centos/docker-ce.repo](https://download.docker.com/linux/centos/docker-ce.repo)

   - yum install docker-ce docker-ce-cli containerd.io
   
   -add daemon.json to allow connection to repository
   
            cat > /etc/docker/daemon.json <<EOF
            {
  
            "insecure-registries":["comlnx94.prod.hclpnp.com"]
  
            }
            EOF

   - systemctl start docker



**Step 3- For each machine, logon as root**

   - **Disable firewall and selinux**
    - Run systemctl disable firewalld
    - Edit the /etc/selinux/config file and set the SELINUX to disabled.
        
            setenforce 0
            sed -i &#39;s/^SELINUX=enforcing$/SELINUX=disabled/&#39; /etc/selinux/config

   - **Load netfilter module for bridge plugin**

    - lsmod | grep br\_netfilter
        
            cat <<EOF> | sudo tee /etc/sysctl.d/k8s.conf
            net.bridge.bridge-nf-call-ip6tables = 1
            net.bridge.bridge-nf-call-iptables = 1
            EOF
    sudo sysctl --system

   - **Disable all partition swap**

    - swapoff –a
    - Free -h
    - Remove swap entry from the /etc/fstab file.
    - systemctl daemon-reload

   - **Make sure iptables tooling does not use nftables backend **
    
    -update-alternatives --set iptables /usr/sbin/iptables-legacy

   **Add kubernetes repo** 

    cat <<EOF> /etc/yum.repos.d/kubernetes.repo
    [kubernetes]
    name=Kubernetes
    baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86\_64
    enabled=1
    gpgcheck=1
    repo\_gpgcheck=1
    gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg
    gpgkey=https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
    EOF

   1. **Import the keys**

     - rpm --import https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
     - rpm --import https://packages.cloud.google.com/yum/doc/yum-key.gpg
     
   2. **Install kubelet, kubeadm and kubectl**

    - yum install -y kubelet kubeadm kubectl

    Note: good practice to exclude these packages from yum updates to avoid unwanted upgrades caused by a general yum update

    For RPM-based distros:
    
        cat <<EOF>> /etc/yum.repos.d/kubernetes.repo
        exclude=kube*
        EOF


    To upgrade:
    
    yum update kubelet kubeadm --disableexcludes=kubernetes

   3. **Enable kubelet**
  - systemctl enable --now kubelet

**Step 4-On Master node:**

   1. Initialize kubeadm

         - kubeadm init --pod-network-cidr=192.168.0.0/16

             - Copy the last few lines from the output. Eg. as in below 
            
              - kubeadm join 10.190.66.183:6443 --token on9bec.k3nkoap08p7cbpbv \  --discovery-token-ca-cert-hash                                       sha256:56f4be2d68ed9b47bf440bf06c2ae65eff61f7e69e6a5d44e6ffeb12ba3f2c9d_
                
                You'll need this in below step 3 to join additional nodes to the cluster. 
                
   2. Create kube config for a regular user with the below commands.
   
     -  mkdir -p $HOME/.kube
     -  sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     -  sudo chown $(id -u):$(id -g) $HOME/.kube/config
                
   3. Now deploy a pod network to the cluster.
        
        Run  
         kubectl apply -f https://docs.projectcalico.org/manifests/calico.yaml
        
        More options and explanation listed at  https://kubernetes.io/docs/concepts/cluster-administration/addons/:      

**Step 5-On Worker node :**

   1. Join any number of worker nodes by running the above copied output from the master nodes on each slave node as root:
       For Eg.
         
            - kubeadm join 10.190.66.183:6443 --token on9bec.k3nkoap08p7cbpbv \--discovery-token-ca-cert-hashsha256:56f4be2d68ed9b47bf440bf06c2ae65eff61f7e69e6a5d44e6ffeb12ba3f2c9d
     
     If the join command fails, you may need to investigate the following
        a - Rerun the same command with one more argument --v=5. This will output more debug information about the errors
        a - Calico pods not up
            On the master, run 
            kubectl get pods --all-namespaces
                  NAMESPACE     NAME                                       READY   STATUS                  RESTARTS   AGE
		      kube-system   calico-kube-controllers-6d8ccdbf46-tkddv   0/1     Pending                 0          105m
			kube-system   calico-node-sgb22                          0/1     Init:ImagePullBackOff   0          105m
           In this case, run 
           kubectl describe pod calico-node-sgb22 -n kube-system
           shows that image docker.io/calico/cni:v3.18.1 failed to be pulled 
           
           Run the command to login to docker 
           docker login --username svt1hclcommerce
           use password 8ee395fd-2204-421f-90b8-de05fbd7f9f1 when requested by the above command
           
           then execute the pull of the image
           docker pull docker.io/calico/cni:v3.18.1
           
           If this is the case of the issue, in general, there will be 3 pulls of the following images 
					docker pull docker.io/calico/cni:v3.18.1
					docker.io/calico/pod2daemon-flexvol:v3.18.1
					docker.io/calico/node:v3.18.1
          
          then delete the pod with the issue, so it can be redeployed automatically using the local image
          kubectl delete the pod calico-node-sgb22
          
          Repeat the above till all the images are pulled and there is no issue with the failed pull. 
          Also pull the image on the master and on the node to be joined
	  
    b - Once Calico pods are all up and join still failing, with this error "Failed to request cluster-info, will try again", 
        then run this on the master 
		systemctl stop firewalld
	    and re run the join command again
     
  2. Copy the kube config file to each node

            - [root@COMP-3246-1 ~] scp -r .kube root@comp-3247-1::~/
            - [root@COMP-3246-1 ~] scp -r .kube root@comp-3248-1::~/
            
      Note :- 3246 Machine is Master node and 3247/3248 are worker nodes

  3. [root@com-kube-master ~]# Verify the cluster by the below 

    kubectl get nodes

    NAME                                 STATUS   ROLES    AGE   VERSION

    com-kube-master.nonprod.hclpnp.com   Ready  master   19d   v1.17.3

    com-kube-node1.nonprod.hclpnp.com    Ready  none   19d   v1.17.3

    com-kube-node2.nonprod.hclpnp.com    Ready  none   19d   v1.17.3

    com-kube-node3.nonprod.hclpnp.com    Ready  none   19d   v1.17.3
    

**Join a new node in cluster:** 

   Later on when you need to join another node, you can follow the previous instruction to set it up to install docker and kubeadm, and     then follow the steps below to join

1. On master node, run kubeadm token create; and it will create a new token valid for 24 hours
2. On the new node, run kubeadm join 10.190.66.183:6443 --token TOKEN; --discovery-token-unsafe-skip-ca-verification
3. After that, verify with kubectl get node; to make sure the new node is ready.

**Reset Cluster**

   Reset kubeadm (Only do this If node crash, or need to re-setup the cluster, do following on each node)


**Kubeadm reset **

   iptables -F && iptables -t nat -F && iptables -t mangle -F && iptables -X

   From [https://blog.heptio.com/properly-resetting-your-kubeadm-bootstrapped-cluster-nodes-heptioprotip-473bd0b824aa](https://blog.heptio.com/properly-resetting-your-kubeadm-bootstrapped-cluster-nodes-heptioprotip-473bd0b824aa);
    
