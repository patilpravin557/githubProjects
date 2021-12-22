
#!/bin/bash
hcl_user_password="PnpRh3l!23"
db2inst1_user_password="diet4coke"
 
echo -e "$hcl_user_password\n" | sudo -S sleep 1 && sudo dd if=/dev/zero of=/mnt/ramdisk/ext4.image bs=1M count=4000
 
yes | sudo mkfs.ext4 /mnt/ramdisk/ext4.image
 
sudo mount -o loop /mnt/ramdisk/ext4.image /mnt/ext4ramdisk
 
sudo chown db2inst1:db2iadm1 /mnt/ext4ramdisk/
 
echo "$db2inst1_user_password\n" | sudo -S sleep 1 && sudo su - db2inst1 -c "db2 update db cfg for mall using NEWLOGPATH /mnt/ext4ramdisk && db2 get db cfg for mall |grep -i log"
