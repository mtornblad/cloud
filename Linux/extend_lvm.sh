echo 1>/sys/class/block/sda/device/rescan
growpart /dev/sda 3
lvextend -l +100%FREE /dev/ubuntu-vg/ubuntu-lv
# resize2fs /dev/mapper/ubuntu–vg-ubuntu–lv
resize2fs /dev/mapper/ubuntu--vg-ubuntu--lv
