#!/usr/bin/env bash

PWD=`pwd`
PWD_RESOLVED=`readlink -f $PWD`

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

function create_vm() {
	type=$1
	vmname=$2
	disk_size=$3
	memory_size=$4
	cores=$5
	rawimage=$6

	echo "Creating VM $vmname, type: $type"

	if [ ! -f "$rawimage" ]; then
		echo "error: raw image file $rawimage was not found"
		exit 1
	fi

	vdifile="$PWD_RESOLVED/$vmname.vdi"

	echo "Shutdown $vmname"
	${VBM} controlvm $vmname poweroff

	echo "Delete $vmname and related files"
	${VBM} unregistervm $vmname --delete

	if [ -f "$vdifile" ]; then
		echo "error: $vdifile exists"
		exit 1
	fi

	echo "Convert disk image for $vmname"
	${VBM} convertfromraw "$rawimage" "$vdifile" --format vdi

	echo "Add more storage space for $vmname.vdi"
	${VBM} modifyhd "$vdifile" --resize $disk_size

	echo "Create VM $vmname"
	${VBM} createvm --name $vmname --register --ostype Linux_64

	echo "Modify VM $vmname"
	${VBM} modifyvm $vmname --memory $memory_size --nic1 intnet --intnet1 abitti --usb off --firmware efi --cpus $cores --vram 16

	echo "Attach storage controller to $vmname"
	${VBM} storagectl $vmname --name SATA --add sata --controller IntelAHCI --portcount 1

	echo "Attach disk image to storage controller"
	${VBM} storageattach $vmname --storagectl "SATA" --device 0 --port 0 --type hdd --medium "$vdifile"

#	echo "Setting independent RTC"
#	${VBM} setextradata $vmname "VBoxInternal/Devices/VMMDev/0/Config/GetHostTimeDisabled" "1"

	if [ "$type" = "koe" ]; then
		echo 'Audio - you may need to change --audio to "oss" or "alsa" instead of "pulse"'
		${VBM} modifyvm $vmname --audio pulse --audiocontroller hda --audioin off --audioout on
	fi
	
	if [ "$type" = "ktp" ]; then
		echo "Shared clipboard"
		${VBM} modifyvm $vmname --clipboard-mode bidirectional

		echo "Shared folder"
		${VBM} sharedfolder add $vmname --name media_usb1 --hostpath ~/ktp-jako
	fi

	echo "Take snapshot"
	${VBM} snapshot $vmname take "Before first boot"
}

create_vm koe Abitti-KOE1 8192 3500 2 koe.dd
# create_vm koe Abitti-KOE2 8192 3500 2 koe.dd
# create_vm koe Abitti-KOE3 8192 3500 2 koe.dd
# create_vm koe Abitti-KOE4 8192 3500 2 koe.dd
# create_vm koe Abitti-KOE5 8192 3500 2 koe.dd
create_vm ktp Abitti-KTP1 16384 8196 4 ktp.dd
create_vm ktp Abitti-KTP2 16384 8196 2 ktp.dd
