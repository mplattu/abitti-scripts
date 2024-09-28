# Abitti Scripts

This repo contains some small scripts related to Abitti course system (see
www.abitti.fi). The scripts are unofficial and they might be outdated.

## Download Abitti images

 * `abitti_dlimg.sh` Downloads current Abitti images to `~/abitti_dlimg.sh`.

## Create Abitti VMs to VirtualBox

These scripts create Abitti virtual machines to Oracle VirtualBox
installation. 

**NB! It is technically possible to create virtual machine and connect this
to the exam network. However, if detected, the consequences can be serious.**

Execute the script in a directory containing server and test-taker images
(`ktp.dd` and `koe.dd`).

Linux and Mac OSX hosts may use `abitti_dlimg.sh` to download images.

 * `abitti_createvm.sh` Create Abitti VMs on Linux and Mac OSX host. The script must be executed in the directory where the images exist.

Windows hosts can
 1. download the current files from download links found at [Abitti.fi](https://www.abitti.fi/fi/paivitykset/).
 1. unzip the image packages
 1. rename the image files `ytl/ktp.img` -> `ktp.dd`, `ytl/koe.img` -> `koe.dd`

 * `abitti_createvm.bat` Create Abitti VMs on Windows host. The script looks disk images from the ancient AbittiUSB location so there is no need to copy images. If the images are not present in profile they are searched from the current directory.

## Start Abitti 2 docker container

There is only Linux script for this. Install the required packages according to the MEB Abitti 2 Linux instructions.

 * Copy `a2_createvm.env.sample` to `a2_createvm.env`.
 * Edit the file to suit your needs.
 * Go to an empty directory (e.g. `~/a2`). The directory should not contain `certs/` nor `ktp-jako/`.
 * Execute `a2_createvm.sh`.

See also:
 * `a2_rmi.sh` to remove all Abitti 2 -related docker images

## Revert Abitti USB stick "back to normal"

`mkfat.sh` overwrites existing partition table, creates a FAT32 partition
and creates a FAT32 filesystem to this partiton. It tries to check whether
the device contains mounted filesystem. Use with caution!

`mkexfat.sh` does the same as above but creates a exFAT filesystem.

`writerandom.sh` writes random data to given device.

## Audio and video conversions

These audio and video conversion scripts are used by the MEB exam coders to
encode media files to the exam:

 * `video-to-webm-40-scale-840x472-norm.sh` Resize and encode video to webm and
   normalize the audio track.
 * `video-to-webm-40-scale-840x472.sh` Same as above but without normalization.
 * `audio-to-ogg.sh` Encode audio files to OGG Vorbis format.

The webm and ogg formats are free and natively supported by Firefox. The conversions
are done by [SoX](https://sourceforge.net/projects/sox/) and [FFmpeg](https://ffmpeg.org/).

