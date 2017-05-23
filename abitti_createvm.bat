@ECHO OFF
SET VBM="c:\program files\oracle\virtualbox\vboxmanage.exe"

rem Shutdown existing VM:s
%VBM% controlvm Abitti-KOE poweroff 
%VBM% controlvm Abitti-KTP poweroff 

rem Delete existing VM:s and related files
%VBM% unregistervm Abitti-KOE --delete
%VBM% unregistervm Abitti-KTP --delete

rem Delete existing disk images
IF NOT EXIST *.vdi GOTO Create_VMs

SET /P ANSWER=VDI files exist. Delete vdi files? (Y/N)? 
IF /i {%ANSWER%}=={y} (GOTO Remove_Disks)
GOTO Create_VMs

:Remove_Disks
del *.vdi

:Create_VMs
rem Convert disk images
%VBM% convertfromraw ktp.dd ktp.vdi --format vdi
%VBM% convertfromraw koe.dd koe.vdi --format vdi

rem Add more size to KOE/KTP image
%VBM% modifyhd "%CD%\ktp.vdi" --resize 8192
%VBM% modifyhd "%CD%\koe.vdi" --resize 8192

rem Create VM
%VBM% createvm --name Abitti-KOE --register --ostype Linux_64
%VBM% createvm --name Abitti-KTP --register --ostype Linux_64

rem Modify VM: Add storage, network, memory...
%VBM% modifyvm Abitti-KOE --memory 2048 --nic1 intnet --intnet1 abitti --usb on --usbehci on --firmware efi --cpus 2
%VBM% modifyvm Abitti-KTP --memory 4096 --nic1 intnet --intnet1 abitti --usb on --usbehci on --firmware efi

%VBM% storagectl Abitti-KOE --name SATA --add sata --controller IntelAHCI --portcount 1
%VBM% storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1

%VBM% storageattach Abitti-KOE --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%CD%\koe.vdi"
%VBM% storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%CD%\ktp.vdi"

%VBM% modifyvm Abitti-KOE --audiocontroller hda

rem Take initial snapshots
%VBM% snapshot Abitti-KOE take "Before first boot"
%VBM% snapshot Abitti-KTP take "Before first boot"

echo "All Done!"
pause
