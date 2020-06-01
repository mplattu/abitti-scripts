#!/usr/bin/env bash

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
${VBM} controlvm Abitti-KOE poweroff 
${VBM} controlvm Abitti-KTP poweroff 

echo "Delete existing VM:s and related files"
${VBM} unregistervm Abitti-KOE --delete
${VBM} unregistervm Abitti-KTP --delete

echo "Delete existing disk images"
if [ -f *.vdi ]; then
    echo "*.vdi files exist. Delete them and re-run."
    exit 1
fi

echo "Convert disk images"
${VBM} convertfromraw ktp.dd ktp.vdi --format vdi
${VBM} convertfromraw koe.dd koe.vdi --format vdi

echo "Add more storage to KTP/KOE image"
${VBM} modifyhd ktp.vdi --resize 16384
${VBM} modifyhd koe.vdi --resize 8192

echo "Create VM"
${VBM} createvm --name Abitti-KOE --register --ostype Linux_64
${VBM} createvm --name Abitti-KTP --register --ostype Linux_64

echo "Modify VM: Add storage, network, memory..."
${VBM} modifyvm Abitti-KOE --memory 4096 --nic1 intnet --intnet1 abitti --usb off --firmware efi --cpus 2
${VBM} modifyvm Abitti-KTP --memory 4096 --nic1 intnet --intnet1 abitti --usb off --firmware efi

${VBM} storagectl Abitti-KOE --name SATA --add sata --controller IntelAHCI --portcount 1
${VBM} storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1

${VBM} storageattach Abitti-KOE --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/koe.vdi"
${VBM} storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/ktp.vdi"

${VBM} modifyvm Abitti-KOE --vram 16
${VBM} modifyvm Abitti-KTP --vram 16

${VBM} modifyvm Abitti-KOE --firmware efi
${VBM} modifyvm Abitti-KTP --firmware efi

echo  'Audio - you may need to change --audio to "oss" or "alsa" instead of "pulse"'
${VBM} modifyvm Abitti-KOE --audio pulse --audiocontroller hda

echo "Shared folder"
${VBM} sharedfolder add Abitti-KTP --name media_usb1 --hostpath ~/ktp-jako

echo "Take initial snapshots"
${VBM} snapshot Abitti-KOE take "Before first boot"
${VBM} snapshot Abitti-KTP take "Before first boot"
