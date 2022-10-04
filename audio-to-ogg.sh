#!/bin/bash
# This is a script use by the MEB exam codes to encode audio files to the exams
#
#  brew install sox --with-libvorbis
#  brew install ffmpeg --with-libvpx --with-libvorbis --with-opus --with-faac
#
# In Debian/Ubuntu, install following:
#  sudo apt install sox ffmpeg

set -e
FILENAME=$1
echo "Converting $FILENAME to ogg, add 1s of silence into beginnig, no normalizing"

ffmpeg -i ${FILENAME} ${FILENAME}_audio_orig.wav
sox ${FILENAME}_audio_orig.wav ${FILENAME%.wav}.ogg pad 1 0
rm ${FILENAME}_audio_orig.wav
