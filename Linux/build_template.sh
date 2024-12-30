sudo apt update
sudo apt -y upgrade
sudo apt -y autoremove
sudo apt clean
sudo apt install vim
sudo truncate -s0 /etc/hostname
sudo hostnamectl set-hostname localhost
sudo rm /etc/netplan/50-cloud-init.yaml
sudo truncate -s0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id
sudo cloud-init clean
sudo passwd -dl root
truncate -s0 ~/.bash_history
history -c

# sudo shutdown -h now
