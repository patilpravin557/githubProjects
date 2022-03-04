gcloud auth login 

gcloud beta compute ssh --zone "asia-south1-c" "perf-cluster-2-db2" --project "commerce-product" 

gsutil cp gs://hclinstallfiles/path/to/file ./destination

pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo lsblk 
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT 
sda 8:0 0 200G 0 disk 
├─sda1 8:1 0 200M 0 part /boot/efi 
└─sda2 8:2 0 199.8G 0 part / 
sdb 8:16 0 1000G 0 disk 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo mkdir -p /mnt/disks/db/dbpath 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo mount -o discard,defaults /dev/sdb /mnt/disks/perf-cluster-2-db2-disk1 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo chmod a+w /mnt/disks/db/dbpath 

 [pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo lsblk 
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT 
sda 8:0 0 200G 0 disk 
├─sda1 8:1 0 200M 0 part /boot/efi 
└─sda2 8:2 0 199.8G 0 part / 
sdb 8:16 0 1000G 0 disk /mnt/disks/perf-cluster-2-db2-disk1 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo cp /etc/fstab /etc/fstab.backup 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo blkid /dev/DEVICE_ID 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo blkid /dev/sdb 
/dev/sdb: UUID="30b60f23-4402-4a5a-ac08-165318678352" TYPE="ext4" 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ echo UUID=`sudo blkid -s UUID -o value /dev/sdb` /mnt/disks/db/dbpath ext4 discard,defaults,nofail 0 2 | sudo tee -a /etc/fstab 
UUID=30b60f23-4402-4a5a-ac08-165318678352 /mnt/disks/perf-cluster-2-db2-disk1 ext4 discard,defaults,nofail 0 2 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ cat /etc/fstab 

# 
# /etc/fstab 
# Created by anaconda on Tue Jun 16 17:59:41 2020 
# 
# Accessible filesystems, by reference, are maintained under '/dev/disk/'. 
# See man pages fstab(5), findfs(8), mount(8) and/or blkid(8) for more info. 
# 
# After editing this file, run 'systemctl daemon-reload' to update systemd 
# units generated from this file. 
# 
UUID=dfddf956-d8b6-480d-8d8b-5d232d9f53fa / xfs defaults 0 0 
UUID=88B0-CB36 /boot/efi vfat defaults,uid=0,gid=0,umask=077,shortname=winnt 0 2 
#UUID=2cf7b106-4189-4207-99dc-429bcfcdb0b7 /mnt/disks/db ext4 discard,defaults,nofail 0 2 
UUID=30b60f23-4402-4a5a-ac08-165318678352 /mnt/disks/perf-cluster-2-db2-disk1 ext4 discard,defaults,nofail 0 2 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ vi /etc/fstab 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ sudo lsblk 
NAME MAJ:MIN RM SIZE RO TYPE MOUNTPOINT 
sda 8:0 0 200G 0 disk 
├─sda1 8:1 0 200M 0 part /boot/efi 
└─sda2 8:2 0 199.8G 0 part / 
sdb 8:16 0 1000G 0 disk /mnt/disks/perf-cluster-2-db2-disk1 
[pravinprakash.patil@perf-cluster-2-db2 ~]$ 

 
 
 [12/8/20 5:45 AM] Raimee Stevens 

gsutil cp gs://hclinstallfiles/path/to/file ./destination 

  

[12/8/20 5:45 AM] Raimee Stevens 

Lydia Siu 

  

[12/8/20 5:45 AM] Raimee Stevens 

will copy file to destination dir. 

  

[12/8/20 6:34 AM] Lydia Siu 

Raimee Stevens, do I need to provide the hostname/pod for destination?   we could have the same path for multiple pods, right?  thx 

  

[12/8/20 6:54 AM] Raimee Stevens 

pod? 

  

[12/8/20 6:55 AM] Raimee Stevens 

You're transferring from a bucket to a vm right? DB server is a VM? 

  

[12/8/20 7:04 AM] Andres Voldman 

Lydia Siu,  you run this from the shell in the DB server 

gsutil cp gs://hclinstallfiles/path/to/file ./destination 
 

  

[12/8/20 7:04 AM] Andres Voldman 

so the destination is in the db machine 

  

[12/8/20 7:04 AM] Andres Voldman 

please see where I mounted the 1TB disk. I think it was /db_data (or similar) 

 
