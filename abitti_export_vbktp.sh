#!/bin/sh
VBM=/usr/bin/VBoxManage

echo "Shutdown existing VM:s"
${VBM} controlvm Abitti-KTP poweroff 

echo "Delete existing VM:s and related files"
${VBM} unregistervm Abitti-KTP --delete

echo "Searching for existing disk images"
if [ -f *.vdi ]; then
    echo "*.vdi files exist. Delete them and re-run."
    exit 1
fi

if [ -f *.ovf ]; then
    echo "*.ovf files exist. Delete them and re-run."
    exit 1
fi

if [ -f *.vmdk ]; then
    echo "*.vmdk files exist. Delete them and re-run."
    exit 1
fi


echo "Convert disk images"
${VBM} convertfromraw ktp.dd ktp.vdi --format vdi

echo "Add more storage to KTP/KOE image"
${VBM} modifyhd ktp.vdi --resize 16384

echo "Create VM"
${VBM} createvm --name Abitti-KTP --register --ostype Linux_64

echo "Modify VM: Add storage, network, memory..."
${VBM} modifyvm Abitti-KTP --memory 4096 --usb off --cpus 2
${VBM} storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1
${VBM} storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/ktp.vdi"
${VBM} modifyvm Abitti-KTP --vram 16
${VBM} modifyvm Abitti-KTP --firmware efi
# Add USB support (USB2 and USB3) - during the test phase
${VBM} modifyvm Abitti-KTP --usb on --usbehci on --usbxhci on

echo "Export virtual machine to OVF file"
${VBM} export Abitti-KTP --ovf20 --vsys 0 --product Abitti --description "Abitti Server" --output abitti-ktp.ovf

