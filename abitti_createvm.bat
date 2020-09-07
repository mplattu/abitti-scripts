@ECHO OFF
SET VBM="c:\program files\oracle\virtualbox\vboxmanage.exe"
SET SHAREDPATH="%HOMEDRIVE%%HOMEPATH%\ktp-jako"

CALL :check_shared_folder
IF NOT %ERRORLEVEL%==0 GOTO end

CALL :create_vm Abitti-KOE
IF NOT %ERRORLEVEL%==0 GOTO end
CALL :create_vm Abitti-KTP1, %SHAREDPATH%
IF NOT %ERRORLEVEL%==0 GOTO end
CALL :create_vm Abitti-KTP2, %SHAREDPATH%
IF NOT %ERRORLEVEL%==0 GOTO end

ECHO All done!
GOTO end


:check_shared_folder
IF EXIST "%SHAREDPATH%" EXIT /B 0
ECHO You need to create shared folder
ECHO %SHAREDPATH%
ECHO to emulate transfer USB stick.
EXIT /B 1


:create_vm
SET vmname=%~1
SET sharedpath=%~2

ECHO Creating VM %vmname%
ECHO Shared path: %sharedpath%
pause

IF %vmname%==Abitti-KOE (SET disk_size=8192) ELSE (SET disk_size=16384)
IF %vmname%==Abitti-KOE (SET memory_size=3500) ELSE (SET memory_size=8196)
IF %vmname%==Abitti-KOE (SET rawimage=koe.dd) ELSE (SET rawimage=ktp.dd)

IF NOT EXIST %rawimage% GOTO error_no_rawimage

ECHO Shutdown %vmname%
%VBM% controlvm %vmname% poweroff

ECHO Delete %vmname% and related files
%VBM% unregistervm %vmname% --delete

rem Make sure there are no settings directory
IF EXIST "%USERPROFILE%\VirtualBox VMs\%vmname%" GOTO error_vbox_vm_dir_exists

ECHO Convert disk image for %vmname%
%VBM% convertfromraw %rawimage% %vmname%.vdi --format vdi

ECHO Add more storage space for %vmname%.vdi
%VBM% modifyhd "%CD%\%vmname%.vdi" --resize %disk_size%

ECHO Create VM %vmname%
%VBM% createvm --name %vmname% --register --ostype Linux_64

ECHO Modify VM %vmname%
%VBM% modifyvm %vmname% --memory %memory_size% --nic1 intnet --intnet1 abitti --usb off --firmware efi --cpus 2 --vram 16

ECHO Attach storage controller to %vmname%
%VBM% storagectl %vmname% --name SATA --add sata --controller IntelAHCI --portcount 1

ECHO Attach disk image to storage controller
%VBM% storageattach %vmname% --storagectl "SATA" --device 0 --port 0 --type hdd --medium "%CD%\%vmname%.vdi"

ECHO Configuring audio, clipboard and shared folder
IF %vmname%==Abitti-KOE %VBM% modifyvm %vmname% --audiocontroller hda --audioin off --audioout on
IF NOT %vmname%==Abitti-KOE %VBM% modifyvm %vmname% --clipboard-mode bidirectional
IF NOT %vmname%==Abitti-KOE %VBM% sharedfolder add %vmname% --name media_usb1 --hostpath=%sharedpath%

ECHO Taking snapshot
%VBM% snapshot %vmname% take "Before first boot"

EXIT /B 0

:error_vbox_vm_dir_exists
ECHO Please delete
ECHO %USERPROFILE%\VirtualBox VMs\%vmname%
ECHO and re-run this script.
EXIT /B 1

:error_no_rawimage
ECHO Raw image %rawimage% is missing.
EXIT /B 1

:end
PAUSE
