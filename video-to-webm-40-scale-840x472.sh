#!/bin/bash
# This is a script used by the MEB exam coders to encode videos to the exams
# To normalize the audio track see video-to-webm-40-scale-840x472-norm.sh
# 
# In macOS, install following tools:
#  brew install sox --with-libvorbis
#  brew install ffmpeg --with-libvpx --with-libvorbis --with-opus --with-faac
#
# In Debian/Ubuntu, install following:
#  sudo apt install sox ffmpeg

set -e
FILENAME=$1
echo "Converting $FILENAME to webm + ogg"

ffmpeg -i ${FILENAME} -c:a libvorbis -vn ${FILENAME}_audio_orig.ogg
ffmpeg -i ${FILENAME} -c:v libvpx-vp9 -crf 40 -b:v 0 -vf scale=840:472 -g 50 -an ${FILENAME}_video_orig.webm
ffmpeg -i ${FILENAME}_video_orig.webm -i ${FILENAME}_audio_orig.ogg -c copy ${FILENAME}_full.webm
rm ${FILENAME}_audio_orig.ogg ${FILENAME}_video_orig.webm
