apt update 
apt -y upgrade
apt -y autoremove
apt clean
truncate -s0 /etc/hostname
hostnamectl set-hostname localhost
rm /etc/netplan/50-cloud-init.yaml
truncate -s0 /etc/machine-id
rm /var/lib/dbus/machine-id
ln -s /etc/machine-id /var/lib/dbus/machine-id
cloud-init clean
passwd -dl root
truncate -s0 ~/.bash_history
history -c
sudo shutdown -h now
