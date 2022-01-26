# Abitti Scripts

This repo contains some small scripts related to Abitti course system (see
www.abitti.fi). The scripts are unofficial and they might be outdated.

## Download Abitti images

 * `abitti_dlimg.sh` Downloads current Abitti images. See variable `FLAVOUR`
   which you can use to download other than production ("prod") images.

## Create Abitti VMs to VirtualBox

These scripts create Abitti virtual machines to Oracle VirtualBox
installation. Execute the script in a directory containing server and
test-taker images (`ktp.dd` and `koe.dd`). Linux and Mac OSX hosts may use
`abitti_dlimg.sh` to download images. Windows hosts can use official AbittiUSB
to do the same. The images are located in `PROFILE/AppData/Local/YtlDigabi/`.

 * `abitti_createvm.sh` Create Abitti VMs on Linux and Mac OSX host. The script must be executed in the directory where the images exist.
 * `abitti_createvm.bat` Create Abitti VMs on Windows host. The script looks disk images from the AbittiUSB location so there is no need to copy images. If the images are not present in profile they are searched from the current directory.

## Run Abitti server in VirtualBox for a local exam network

`abitti_createvm` creates internal network which connects test taker's workstation and the server. Internal here means internal to the VirtualBox. However, it is technically possible to run server as a VirtualBox machine and connect it to your local network. Local here means the local Ethernet (or wireless) network. Before building the setup please make sure that your VirtualBox license allows you to do this.

 1) Install VirtualBox and Extension Pack as you need USB support.
 2) Create Abitti VMs using `abitti_createvm`. 
 3) Change the Abitti-KTP settings from the VirtualBox Settings:
  * Settings
  * Network
  * Adapter 1 is not connected to an "Internal Network" called "abitti". Change this:
  * Attached to: Bridged Adapter
  * Name: Select your Ethernet interface
 
Finally, make sure your host does not bind to the Ethernet interface. If your host asks network settings using DHCP the Abitti server reports is as "unknown device" in the terminal view.

`abitti_export_vbktp.sh` creates a OVF2.0 export from the current `ktp.dd`.

## Revert Abitti USB stick "back to normal"

`mkfat.sh` overwrites existing partition table, creates a FAT32 partition
and creates a FAT32 filesystem to this partiton. It tries to check whether
the device contains mounted filesystem. Use with caution!

`mkexfat.sh` does the same as above but creates a exFAT filesystem.

