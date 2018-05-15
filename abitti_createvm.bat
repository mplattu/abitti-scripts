@ECHO OFF
SET VBM="c:\program files\oracle\virtualbox\vboxmanage.exe"
SET SHAREDPATH="%HOMEDRIVE%%HOMEPATH%\ktp-jako"

rem Make sure we have the dd images (use AbittiUSB to download these)
IF NOT EXIST %LOCALAPPDATA%\YtlDigabi\koe.dd GOTO no_image_prof
IF NOT EXIST %LOCALAPPDATA%\YtlDigabi\ktp.dd GOTO no_image_prof
ECHO Images were found at %LOCALAPPDATA%\YtlDigabi\
SET KOE_PATH="%LOCALAPPDATA%\YtlDigabi\koe.dd"
SET KTP_PATH="%LOCALAPPDATA%\YtlDigabi\ktp.dd"
ECHO Using images from the profile:
ECHO KOE image path: %KOE_PATH%
ECHO KTP image path: %KTP_PATH%
GOTO check_shared_folder

:no_image_prof
ECHO Images missing (%LOCALAPPDATA%\YtlDigabi\*.dd)
IF NOT EXIST .\koe.dd GOTO no_image_here
IF NOT EXIST .\ktp.dd GOTO no_image_here
SET KOE_PATH=".\koe.dd"
SET KTP_PATH=".\ktp.dd"
ECHO Using images from the current directory:
ECHO KOE image path: %KOE_PATH%
ECHO KTP image path: %KTP_PATH%
GOTO check_shared_folder

:no_image_here
ECHO Images missing (.\*.dd)
ECHO Use either standard AbittiUSB or your browser to download the images.
GOTO end

:check_shared_folder
IF EXIST "%SHAREDPATH%" GOTO create_vms
ECHO You need to create shared folder
ECHO %SHAREDPATH%
ECHO to emulate transfer USB stick.
GOTO end

:create_vms
rem Shutdown existing VM:s
%VBM% controlvm Abitti-KOE poweroff 
%VBM% controlvm Abitti-KTP poweroff 

rem Delete existing VM:s and related files
%VBM% unregistervm Abitti-KOE --delete
%VBM% unregistervm Abitti-KTP --delete

rem Make sure there are no settings directory
IF NOT EXIST "%USERPROFILE%\VirtualBox VMs" GOTO vbox_directory_missing
IF EXIST "%USERPROFILE%\VirtualBox VMs\Abitti-KOE" GOTO vbox_vm_dir_exists
IF EXIST "%USERPROFILE%\VirtualBox VMs\Abitti-KTP" GOTO vbox_vm_dir_exists
GOTO check_vdifiles

:vbox_vm_dir_exists
ECHO You have at least one of these two directories:
ECHO 1) %USERPROFILE%\VirtualBox VMs\Abitti-KOE
ECHO 2) %USERPROFILE%\VirtualBox VMs\Abitti-KTP
ECHO Please delete these directories and re-run this script.
GOTO end

:vbox_directory_missing
ECHO Directory %USERPROFILE%\Virtualbox VMs is missing.
ECHO Execute VirtualBox at least once to create it.
GOTO end
 
:check_vdifiles
rem Delete existing disk images
IF NOT EXIST *.vdi GOTO convert_disks

SET /P ANSWER=VDI files exist. Delete vdi files? (Y/N)? 
IF /i {%ANSWER%}=={y} (GOTO Remove_Disks)
GOTO convert_disks

:Remove_Disks
del *.vdi

:convert_disks
rem Convert disk images
%VBM% convertfromraw %KTP_PATH% ktp.vdi --format vdi
%VBM% convertfromraw %KOE_PATH% koe.vdi --format vdi
rem %VBM% convertfromraw ktp_padded.dd ktp.vdi --format vdi
rem %VBM% convertfromraw koe_padded.dd koe.vdi --format vdi

rem Add more size to KOE/KTP image
%VBM% modifyhd "%CD%\ktp.vdi" --resize 8192
%VBM% modifyhd "%CD%\koe.vdi" --resize 8192

rem Create VM
%VBM% createvm --name Abitti-KOE --register --ostype Linux_64
%VBM% createvm --name Abitti-KTP --register --ostype Linux_64

rem Modify VM: Add storage, network, memory...
%VBM% modifyvm Abitti-KOE --memory 2048 --nic1 intnet --intnet1 abitti --firmware efi --cpus 2
%VBM% modifyvm Abitti-KTP --memory 4096 --nic1 intnet --intnet1 abitti --firmware efi --cpus 2

%VBM% storagectl Abitti-KOE --name SATA --add sata --controller IntelAHCI --portcount 1
%VBM% storagectl Abitti-KTP --name SATA --add sata --controller IntelAHCI --portcount 1

%VBM% storageattach Abitti-KOE --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%CD%\koe.vdi"
%VBM% storageattach Abitti-KTP --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%CD%\ktp.vdi"

REM If you have problems with audio try different audio controllers: "ac97", "hda", "sb16"
%VBM% modifyvm Abitti-KOE --audiocontroller ac97

rem Shared folder
%VBM% sharedfolder add Abitti-KTP --name media_usb1 --hostpath %SHAREDPATH%

rem Take initial snapshots
%VBM% snapshot Abitti-KOE take "Before first boot"
%VBM% snapshot Abitti-KTP take "Before first boot"

echo All Done!
:end
pause
