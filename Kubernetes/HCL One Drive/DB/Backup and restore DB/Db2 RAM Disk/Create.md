[db2inst1@COMP-2228-1 db2_backup]$ who -b 

         system boot  2020-10-08 12:42 

[db2inst1@COMP-2228-1 db2_backup]$ 

 

 

[hcluser@COMP-2228-1 /]$ ll 

total 32 

lrwxrwxrwx.   1 root     root         7 Jan 17  2019 bin -> usr/bin 

dr-xr-xr-x.   5 root     root      4096 Aug  1 06:14 boot 

drwxr-xr-x.   2 root     root         6 Jan 23  2019 cdrom 

drwxr-xr-x.   3 db2inst1 db2iadm1    22 Jun 25 15:08 database 

drwxr-xr-x.  10 root     root       133 Jul 13 12:30 db 

drwxr-xr-x.  20 root     root      3460 Sep 21 01:35 dev 

drwxr-xr-x. 185 root     root     12288 Sep 21 01:35 etc 

drwxr-xr-x.   8 root     root        95 May 27 17:37 home 

lrwxrwxrwx.   1 root     root         7 Jan 17  2019 lib -> usr/lib 

lrwxrwxrwx.   1 root     root         9 Jan 17  2019 lib64 -> usr/lib64 

drwxr-xr-x.   2 root     root         6 Apr 29 10:15 media 

drwxr-xr-x.   4 root     root        40 Apr 29 10:20 mnt 

 

 

[hcluser@COMP-2228-1 /]$ sudo dd if=/dev/zero of=/mnt/ramdisk/ext4.image bs=1M count=4000 

[sudo] password for hcluser:PnpRh3l!23 

4000+0 records in 

4000+0 records out 

4194304000 bytes (4.2 GB) copied, 2.21186 s, 1.9 GB/s 

[hcluser@COMP-2228-1 /]$ 

 

 

[hcluser@COMP-2228-1 /]$ sudo mkfs.ext4 /mnt/ramdisk/ext4.image 

mke2fs 1.42.9 (28-Dec-2013) 

/mnt/ramdisk/ext4.image is not a block special device. 

Proceed anyway? (y,n) y 

Discarding device blocks: done 

Filesystem label= 

OS type: Linux 

Block size=4096 (log=2) 

Fragment size=4096 (log=2) 

Stride=0 blocks, Stripe width=0 blocks 

256000 inodes, 1024000 blocks 

51200 blocks (5.00%) reserved for the super user 

First data block=0 

Maximum filesystem blocks=1048576000 

32 block groups 

32768 blocks per group, 32768 fragments per group 

8000 inodes per group 

Superblock backups stored on blocks: 

        32768, 98304, 163840, 229376, 294912, 819200, 884736 

  

Allocating group tables: done 

Writing inode tables: done 

Creating journal (16384 blocks): done 

Writing superblocks and filesystem accounting information: done 

  

  

[hcluser@COMP-2228-1 /]$ sudo mount -o loop /mnt/ramdisk/ext4.image /mnt/ext4ramdisk 

 

 

[db2inst1@COMP-2228-1 /]$ df -k 

Filesystem             1K-blocks      Used Available Use% Mounted on 

devtmpfs                16372988         0  16372988   0% /dev 

tmpfs                   16389976        16  16389960   1% /dev/shm 

tmpfs                   16389976     10096  16379880   1% /run 

tmpfs                   16389976         0  16389976   0% /sys/fs/cgroup 

/dev/mapper/rhel-root  143668720  62057484  81611236  44% / 

/dev/sda1                1038336    292200    746136  29% /boot 

/dev/mapper/dbvg-dblv 1073217536 253948136 819269400  24% /db 

/dev/mapper/rhel-home   18950144  16158028   2792116  86% /home 

tmpfs                    3277996        40   3277956   1% /run/user/1001 

/dev/loop0               3966144     15992   3728968   1% /mnt/ext4ramdisk 

 

sudo chown db2inst1:db2iadm1 /mnt/ext4ramdisk/ 

 

[db2inst1@COMP-2228-1 /]$ db2 update db cfg for mall using NEWLOGPATH /mnt/ext4ramdisk 

DB20000I  The UPDATE DATABASE CONFIGURATION command completed successfully. 

[db2inst1@COMP-2228-1 /]$ 

 

 

*******************************************Error************ 

[db2inst1@COMP-2228-1 ~]$ db2 update db cfg for mall using newlogpath /mnt/ext4ramdisk 

SQL5099N  The value "/mnt/ext4ramdisk/" indicated by the database 

configuration parameter "NEWLOGPATH" is not valid, reason code "9". 

SQLSTATE=08004 

[db2inst1@COMP-2228-1 ~]$ exit 

logout 

[hcluser@COMP-2228-1 mnt]$ ll 

total 4 

drwxr-xr-x. 3 root     root     4096 Oct  9 07:57 ext4ramdisk 

drwxr-xr-x. 2 db2inst1 db2iadm1   24 Sep 23 14:17 ramdisk 

[hcluser@COMP-2228-1 mnt]$ cd .. 

Solution 

[hcluser@COMP-2228-1 /]$ sudo chown db2inst1:db2iadm1 /mnt/ext4ramdisk/ 

***************************************************************************** 

 

 

sudo chown db2inst1:db2iadm1 /mnt/ext4ramdisk/ 

 

 

[db2inst1@COMP-2228-1 /]$ db2 update db cfg for mall using NEWLOGPATH /mnt/ext4ramdisk 

DB20000I  The UPDATE DATABASE CONFIGURATION command completed successfully. 

 

[db2inst1@COMP-2228-1 /]$ db2 get db cfg for mall |grep -i log 

Log retain for recovery status                          = NO 

User exit for logging status                            = NO 

Catalog cache size (4KB)              (CATALOGCACHE_SZ) = 16384 

Log buffer size (4KB)                        (LOGBUFSZ) = 2149 

Log file size (4KB)                         (LOGFILSIZ) = 8192 

Number of primary log files                (LOGPRIMARY) = 12 

Number of secondary log files               (LOGSECOND) = 10 

Changed path to log files                  (NEWLOGPATH) = /mnt/ext4ramdisk/NODE0000/LOGSTREAM0000/ 

Path to log files                                       = /db/dbpath/db2inst1/NODE0000/SQL00001/LOGSTREAM0000/ 

 

 

[db2inst1@COMP-2228-1 /]$ db2 restart db mall 

DB20000I  The RESTART DATABASE command completed successfully. 

[db2inst1@COMP-2228-1 /]$ db2 get db cfg for mall |grep -i log 

Log retain for recovery status                          = NO 

User exit for logging status                            = NO 

Catalog cache size (4KB)              (CATALOGCACHE_SZ) = 16384 

Log buffer size (4KB)                        (LOGBUFSZ) = 2149 

Log file size (4KB)                         (LOGFILSIZ) = 8192 

Number of primary log files                (LOGPRIMARY) = 12 

Number of secondary log files               (LOGSECOND) = 10 

Changed path to log files                  (NEWLOGPATH) = 

Path to log files                                       = /mnt/ext4ramdisk/NODE0000/LOGSTREAM0000/ 

Overflow log path                     (OVERFLOWLOGPATH) = 

Mirror log path                         (MIRRORLOGPATH) = 

First active log file                                   = 

Block log on disk full                (BLK_LOG_DSK_FUL) = NO 

 

 

 

 

[db2inst1@COMP-2228-1 ~]$ db2 restore db mall from /home/db2inst1/db2_backup/ taken at 20200923131501 

SQL2539W  The specified name of the backup image to restore is the same as the 

name of the target database.  Restoring to an existing database that is the 

same as the backup image database will cause the current database to be 

overwritten by the backup version. 

Do you want to continue ? (y/n) y 

DB20000I  The RESTORE DATABASE command completed successfully. 

 

 

 

[db2inst1@COMP-2228-1 ~]$ db2 restore db MALL from /home/db2inst1/db2_backup/ TAKEN AT 20200923131501 TO AUTH INTO AUTH 

SQL2528W  Warning!  Restoring to an existing database that is the same as the 

backup image database, but the alias name "AUTH" of the existing database does 

not match the alias "MALL" of backup image, and the database name "AUTH" of 

the existing database does not match the database name "MALL" of the backup 

image.  The target database will be overwritten by the backup version. 

Do you want to continue ? (y/n) y 

DB20000I  The RESTORE DATABASE command completed successfully. 

 

 

db2diag -f 

  988  db2 get db cfg |grep -i log 

  989  db2 get db cfg for mall |grep -i log 

  990  db2 get dbm cfg | grep diag 

  991  db2 get dbm cfg 

 

 

 

If we did not the change in path do below 

 

[db2inst1@COMP-2228-1 ~]$ db2 force applications all 

DB20000I  The FORCE APPLICATION command completed successfully. 

DB21024I  This command is asynchronous and may not be effective immediately. 

  

[db2inst1@COMP-2228-1 ~]$ db2 restart db mall 

DB20000I  The RESTART DATABASE command completed successfully. 

[db2inst1@COMP-2228-1 ~]$ db2 get db cfg for mall |grep -i log 

 

[db2inst1@COMP-2228-1 ~]$ db2 get db cfg for mall |grep -i log 

Log retain for recovery status                          = NO 

User exit for logging status                            = NO 

Catalog cache size (4KB)              (CATALOGCACHE_SZ) = 16384 

Log buffer size (4KB)                        (LOGBUFSZ) = 2149 

Log file size (4KB)                         (LOGFILSIZ) = 8192 

Number of primary log files                (LOGPRIMARY) = 12 

Number of secondary log files               (LOGSECOND) = 10 

Changed path to log files                  (NEWLOGPATH) = 

Path to log files                                       = /mnt/ext4ramdisk/NODE0000/LOGSTREAM0000/ 

Overflow log path                     (OVERFLOWLOGPATH) = 

Mirror log path                         (MIRRORLOGPATH) = 

First active log file                                   = 
