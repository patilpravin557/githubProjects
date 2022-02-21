# K8s Architecture 

API Server 

    -  Act as front end for kubernetes 

    -  Users ,command line interfaces all talk to  API servers 

 

Etcd 

    - Key-value store  

     - hold the information of all the nods in the cluster in distributed manner 

 

Scheduler 

    - Responsible for distributing work across containers 

    - look for newly created containers and assigned them to nodes 

 

Controller 

   -  brain behind orchestration 

   -  responsible for noticing nodes, containers, end points goes down 

 

Container runtime 

  - Is underline software is used to run the container 

  - eg. Docker 

 

Kublet  

   -   is the agent which runs on each node in cluster 

   -   make sure containers are running on nodes as expected  

 

 

 

Worker Node 

   - where container runtime runs eg. Docker 

   - Kubelet present on worker which communicates with master to provide healt info of nodes 

 

Master 

  - kube api server  

  - etcd – all key value info store 

  - controller 

  - scheduler 

 

Command line utility 

  kubectl 
