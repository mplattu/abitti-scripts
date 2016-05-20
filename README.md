# Abitti Scripts

This repo contains some small scripts related to Abitti course system (see
www.abitti.fi). The scripts are unofficial and they might be outdated.

## Download Abitti images

 * `abitti_dlimg.sh` Downloads current Abitti images. See variable `FLAVOUR`
   which you can use to download other than production ("prod") images.

## Create Abitti VMs to VirtualBox

These scripts create Abitti virtual machines to Oracle VirtualBox
installation. Execute the script in a directory containing server and
test-taker images (`ktp.dd` and `koe.dd`). Linux hosts may use
`abitti_dlimg.sh` to download images. Windows hosts can use official AbittiUSB
to do the same. The images are located in PROFILE/AppData/Local/YtlDigabi/.

 * `abitti_createvm.sh` Create Abitti VMs on Linux host.
 * `abitti_createvm.bat` Create Abitti VMs on Windows host.

