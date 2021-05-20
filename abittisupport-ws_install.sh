#!/bin/sh

# This workstation creates workstation for Abitti-support
# Before executing this install Ubuntu 20.04 (we used Xubuntu flavour)

ABITTIUSER=$USER

# Install VirtualBox, Vagrant and Naksu

echo "Create apt source entry for VirtualBox"
echo "deb [arch=amd64] https://download.virtualbox.org/virtualbox/debian focal contrib" >virtualbox-oracle.list
sudo cp virtualbox-oracle.list /etc/apt/sources.list.d/virtualbox-oracle.list

echo "Get Virtualbox signature and install Virtualbox"
wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
sudo apt update
sudo apt install virtualbox-6.1
adduser $ABITTIUSER vboxusers

echo "Get and install Vagrant"
wget -c https://releases.hashicorp.com/vagrant/2.2.10/vagrant_2.2.10_x86_64.deb
sudo apt install ./vagrant_2.2.10_x86_64.deb

echo "Get and install naksu"
wget -c https://github.com/digabi/naksu/releases/download/v1.12.2/naksu_linux_amd64.zip
unzip naksu_linux_amd64.zip
mv naksu /home/$ABITTIUSER/Desktop/
chown $ABITTIUSER.$ABITTIUSER /home/$ABITTIUSER/Desktop/naksu
chmod 755 /home/$ABITTIUSER/Desktop/naksu

# Install Teams

echo "Get and install Teams"
wget -c https://packages.microsoft.com/repos/ms-teams/pool/main/t/teams/teams_1.3.00.16851_amd64.deb
sudo apt install ./teams_1.3.00.16851_amd64.deb

# Install git etc

echo "Install git"
sudo apt install git

echo "Get and install Abitti images"
if [ ! -d ~/ktp-jako ]; then
	mkdir ~/ktp-jako
fi

git clone https://github.com/mplattu/abitti-scripts.git
if [ ! -d ~/abitti.v227 ]; then
	abitti-scripts/abitti_dlimg.sh
fi

cd abitti.v227
~/abitti-scripts/abitti_createvm.sh

