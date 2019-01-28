#!/usr/bin/env bash

if [ "$1" = "" ]; then
	echo "usage: $0 server_diskimage.vmdk"
	echo ""
	echo "Creates virtual Abitti server using given disk image"
	exit 1
fi

if [ "$(uname)" == "Darwin" ]; then
    # Running on Mac OSX
    VBM=/Applications/VirtualBox.app/Contents/Resources/VirtualBoxVM.app/Contents/MacOS/VBoxManage
    if [ ! -f $VBM ]; then
        echo "You seem to be running Mac OSX operating system."
        echo "VirtualBox's VBoxManage command line tool was not found at:"
        echo $VBM
        echo "Exiting"
        exit
    fi
else
    # Running on Linux
    VBM=/usr/bin/VBoxManage
    if [ ! -f $VBM ]; then
        echo "You seem to be running Linux operating system."
        echo "VirtualBox's VBoxManage command line tool was not found at:"
        echo $VBM
        echo "Exiting"
        exit
    fi
fi

if [ ! -d ~/ktp-jako ]; then
    echo "You need to create shared folder ~/ktp-jako to emulate transfer USB stick."
    echo "Exiting"
    exit
fi

echo "Shutdown existing VM:s"
${VBM} controlvm Abitti-KTP poweroff 

echo "Delete existing VM:s and related files"
${VBM} unregistervm Abitti-KTP --delete

echo "Create VM"
${VBM} createvm --name Abitti-KTP --register --ostype Linux_64

echo "Modify VM: Add storage, network, memory..."
${VBM} modifyvm Abitti-KTP --memory 4096 --nic1 intnet --intnet1 abitti --usb off --firmware efi

${VBM} storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1

${VBM} storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/$1"

${VBM} modifyvm Abitti-KTP --vram 16

${VBM} modifyvm Abitti-KTP --firmware efi

echo "Shared folder"
${VBM} sharedfolder add Abitti-KTP --name media_usb1 --hostpath ~/ktp-jako

echo "Take initial snapshots"
${VBM} snapshot Abitti-KTP take "Before first boot"
