VBM=/usr/bin/VBoxManage

# Shutdown existing VM:s
${VBM} controlvm Abitti-KOE poweroff 
${VBM} controlvm Abitti-KTP poweroff 

# Delete existing VM:s and related files
${VBM} unregistervm Abitti-KOE --delete
${VBM} unregistervm Abitti-KTP --delete

# Delete existing disk images
if [ -f *.vdi ]; then
    echo "*.vdi files exist. Delete them and re-run."
    exit 1
fi

# Convert disk images
${VBM} convertfromraw ktp.dd ktp.vdi --format vdi
${VBM} convertfromraw koe.dd koe.vdi --format vdi

# Add more storage to KOE/KTP image
${VBM} modifyhd ktp.vdi --resize 8192
${VBM} modifyhd koe.vdi --resize 8192

# Create VM
${VBM} createvm --name Abitti-KOE --register --ostype Linux_64
${VBM} createvm --name Abitti-KTP --register --ostype Linux_64

# Modify VM: Add storage, network, memory...
${VBM} modifyvm Abitti-KOE --memory 2048 --nic1 intnet --intnet1 abitti --usb on --usbehci on --firmware efi --cpus 2
${VBM} modifyvm Abitti-KTP --memory 4096 --nic1 intnet --intnet1 abitti --usb on --usbehci on --firmware efi

${VBM} storagectl Abitti-KOE --name SATA --add sata --controller IntelAHCI --portcount 1
${VBM} storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1

${VBM} storageattach Abitti-KOE --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/koe.vdi"
${VBM} storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/ktp.vdi"

${VBM} modifyvm Abitti-KOE --vram 16
${VBM} modifyvm Abitti-KTP --vram 16

${VBM} modifyvm Abitti-KOE --firmware efi
${VBM} modifyvm Abitti-KTP --firmware efi

# Audio - you may need to change --audio to "oss" or "alsa" instead of "pulse"
${VBM} modifyvm Abitti-KOE --audio pulse --audiocontroller hda

# Take initial snapshots
${VBM} snapshot Abitti-KOE take "Before first boot"
${VBM} snapshot Abitti-KTP take "Before first boot"
