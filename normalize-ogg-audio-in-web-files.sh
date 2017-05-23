#!/bin/sh
# Install needed tools:
# apt-get install sox
# apt-get install ffmpeg
set -e
FILENAME=$1
echo "Converting $FILENAME to webm + ogg with normalized audio"

ffmpeg -i ${FILENAME} -c:a libvorbis -vn ${FILENAME}_audio_orig.ogg
ffmpeg -i ${FILENAME} -c:v libvpx-vp9 -crf 50 -b:v 0 -vf scale=840:-1 -g 50 -an ${FILENAME}_video_orig.webm
sox --norm ${FILENAME}_audio_orig.ogg ${FILENAME}_audio_norm.ogg
ffmpeg -i ${FILENAME}_video_orig.webm -i ${FILENAME}_audio_norm.ogg -c copy ${FILENAME}_normalized_full.webm
rm ${FILENAME}_audio_orig.ogg ${FILENAME}_video_orig.webm ${FILENAME}_audio_norm.ogg

