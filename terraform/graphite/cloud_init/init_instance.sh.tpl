#!/bin/bash

# add 10GB to tmp partition
lvextend -L +10G /dev/mapper/vg_system-tmp
xfs_growfs /dev/mapper/vg_system-tmp

# add 10GB to log partition
lvextend -L +10G /dev/vgname/lv_opt
xfs_growfs /dev/vgname/lv_opt

# apply free space on disk to lvm root partition
lvextend -l +100%FREE /dev/mapper/vg_system-root
xfs_growfs /dev/mapper/vg_system-root

# mount ebs volume to /data
mkfs -t xfs /dev/xvdh
mkdir /data
mount /dev/xvdh /data