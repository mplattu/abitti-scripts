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
        exit 1
    fi
fi

if [ ! -d ~/ktp-jako ]; then
    echo "You need to create shared folder ~/ktp-jako to emulate transfer USB stick."
    echo "Exiting"
    exit 1
fi

if [ -f *.vdi ]; then
    echo "*.vdi files exist. Delete them and re-run."
    exit 1
fi


function create_vm() {
	vmname=$1

	echo "Creating VM $vmname"

	disk_size=16384
	memory_size=8196
	rawimage=ktp.dd

	if [ "$vmname" = "Abitti-KOE" ]; then
		# Default settings for student's VM
		disk_size=8192
		memory_size=3500
		rawimage=koe.dd
	fi

	if [ ! -f $rawimage ]; then
		echo "Could not find raw disk image: $rawimage"
		exit 1
	fi

	echo "Shutdown $vmname"
	${VBM} controlvm $vmname poweroff

	echo "Delete $vmname and related files"
	${VBM} unregistervm $vmname --delete

	echo "Convert disk image for $vmname"
	${VBM} convertfromraw $rawimage $vmname.vdi --format vdi

	echo "Add more storage space for $vmname.vdi"
	${VBM} modifyhd $vmname.vdi --resize $disk_size

	echo "Create VM $vmname"
	${VBM} createvm --name $vmname --register --ostype Linux_64

	echo "Modify VM $vmname"
	${VBM} modifyvm $vmname --memory $memory_size --nic1 intnet --intnet1 abitti --usb off --firmware efi --cpus 2 --vram 16

	echo "Attach storage controller to $vmname"
	${VBM} storagectl $vmname --name SATA --add sata --controller IntelAHCI --portcount 1

	echo "Attach disk image to storage controller"
	${VBM} storageattach $vmname --storagectl "SATA" --device 0 --port 0 --type hdd --medium "`pwd`/$vmname.vdi"

	if [ "$vmname" = "Abitti-KOE" ]; then
		echo 'Audio - you may need to change --audio to "oss" or "alsa" instead of "pulse"'
		${VBM} modifyvm $vmname --audio pulse --audiocontroller hda --audioin off --audioout on
	else
		echo "Shared clipboard"
		${VBM} modifyvm $vmname --clipboard-mode bidirectional

		echo "Shared folder"
		${VBM} sharedfolder add $vmname --name media_usb1 --hostpath ~/ktp-jako
	fi

	echo "Take snapshot"
	${VBM} snapshot $vmname take "Before first boot"
}

create_vm Abitti-KOE
create_vm Abitti-KTP1
create_vm Abitti-KTP2
