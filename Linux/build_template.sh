sudo lvextend --resizefs -l +100%FREE ubuntu-vg/ubuntu-lv
sudo apt update
sudo apt -y upgrade
sudo apt -y install cloud-init open-vm-tools vim
sudo apt -y autoremove
sudo apt clean

sudo vmtoolsd -v
sudo cloud-init -v

sudo systemctl is-enabled open-vm-tools.service
sudo systemctl is-enabled cloud-init.service
sudo systemctl is-enabled cloud-init-local.service

sudo truncate -s0 /etc/hostname
sudo hostnamectl set-hostname localhost
sudo rm /etc/netplan/50-cloud-init.yaml
sudo truncate -s0 /etc/machine-id
sudo rm /var/lib/dbus/machine-id
sudo ln -s /etc/machine-id /var/lib/dbus/machine-id

sudo tee /etc/cloud/cloud.cfg.d/vmware.cfg > /dev/null <<'TXT'
datasource_list: [OVF]
disable_vmware_customization: true
datasource:
  OVF:
    allow_raw_data: true
vmware_cust_file_max_wait: 25
TXT

sudo cloud-init clean

sudo passwd -dl root
truncate -s0 ~/.bash_history
history -c

# sudo poweroff
