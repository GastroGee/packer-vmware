#!/usr/bin/env bash

# Update to the latest kernel
apt-get install -y linux-generic linux-image-generic

# Hide Ubuntu splash screen during OS Boot, so you can see if the boot hangs
apt-get remove -y plymouth-theme-ubuntu-text
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="quiet"/GRUB_CMDLINE_LINUX_DEFAULT=""/' /etc/default/grub
update-grub

###Install basic tools
apt-get install -y wget -q unzip git jq curl net-tools

## Install Molecule
python3 -m pip install --user "molecule[docker,lint]"

## Install
snap install j2

#### python and pip stuff
apt-get install -y python3-pip
apt-get install -y python3-venv
apt-get install -y sshpass
apt-get clean

echo "Done with base packages ..... "
# Reboot with the new kernel
# shutdown -r now
# sleep 60

exit 0