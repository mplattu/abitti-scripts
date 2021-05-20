#!/usr/bin/env bash

# Downloads and unpacks Abitti (www.abitti.fi) disk images.
#
# This script is public domain.
#
# This script is not supported by Matriculation Examination Board of
# Finland. The download URLs may change without any notice. For
# supported tools see www.abitti.fi.

IMAGEPATH=~/abitti_images

if [ "$(uname)" == "Darwin" ]; then
	# MacOS download command
	DLCMD_TOFILE="curl -o"
	DLCMD_STDOUT="curl"
else
	# Download command for other unices
	DLCMD_TOFILE="wget -c -O"
	DLCMD_STDOUT="wget --quiet -O -"
fi


report_error() {
	echo -------Error---------------------------------
	echo $1 >&2
	echo ---------------------------------------------
	exit 1
}

report_warning() {
    MESSAGE=$1
    echo -------Warning-------------------------------
    echo $1
    echo ---------------------------------------------
}

download_and_unzip() {
	
	
	if [ "$(uname)" == "Darwin" ]; then
		curl -O http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip.md5 # Mac OSX
	else
		wget -c http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip.md5 # Linux
	fi
	if [ $? -ne 0 ]; then
		report_error "Failed to download image '${TAG}' MD5: $?"
	fi
	
	if [ "$(uname)" == "Darwin" ]; then
		curl -O http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip # Mac OSX
	else
		wget -c http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip # Linux
	fi
	if [ $? -ne 0 ]; then
		report_error "Failed to download image '${TAG}': $?"
	fi
	
	cat ${TAG}.zip.md5 | $MD5
	if [ $? -ne 0 ]; then
		report_error "Failed to verify image '${TAG}': $?"
	fi
	
	unzip ${TAG}.zip
	if [ $? -ne 0 ]; then
		report_error "Failed to unzip image '${TAG}': $?"
	fi
	
	# Remove temporary files
	rm ${TAG}.zip
	rm ${TAG}.zip.md5
}

download_and_extract() {
	ZIP_URL=$1
	ZIP_PATH=$2
	FILE_INSIDE_ZIP=$3
	FILE_OUTSIDE_ZIP=$4
	
	ZIP_FILE=`basename $ZIP_URL`
	
	if [ ! -d $ZIP_PATH ]; then
		mkdir -p $ZIP_PATH
	fi
	
	if [ -f $ZIP_PATH/$ZIP_FILE ]; then
		echo "File $ZIP_PATH/$ZIP_FILE already exists"
	else
		$DLCMD_TOFILE $ZIP_PATH/$ZIP_FILE $ZIP_URL
	fi
	
	
	if [ -f $ZIP_PATH/$FILE_OUTSIZE_ZIP ]; then
		echo "File $ZIP_PATH/$FILENAME_OUTSIDE_ZIP already exists"
	else
		BASENAME_INSIDE_ZIP=`basename $FILE_INSIDE_ZIP`
		unzip $ZIP_PATH/$ZIP_FILE $FILE_INSIDE_ZIP -d $ZIP_PATH
		mv $ZIP_PATH/$FILE_INSIDE_ZIP $ZIP_PATH/$FILE_OUTSIDE_ZIP
	fi
	
	if [ -d $ZIP_PATH/ytl ]; then
		rmdir $ZIP_PATH/ytl
	fi
}

NEW_VERSION_ABITTI=`${DLCMD_STDOUT} https://static.abitti.fi/etcher-usb/koe-etcher.ver`
if [ ! -f ${IMAGEPATH}/${NEW_VERSION_ABITTI}/koe.dd ]; then
	echo "Must download new Abitti (${NEW_VERSION_ABITTI})"
	download_and_extract https://static.abitti.fi/etcher-usb/koe-etcher.zip ${IMAGEPATH}/${NEW_VERSION_ABITTI} ytl/koe.img koe.dd
fi

NEW_VERSION_SERVER=`${DLCMD_STDOUT} https://static.abitti.fi/etcher-usb/ktp-etcher.ver`
if [ ! -f ${IMAGEPATH}/${NEW_VERSION_SERVER}/ktp.dd ]; then
	echo "Must download new server (${NEW_VERSION_SERVER})"
	download_and_extract https://static.abitti.fi/etcher-usb/ktp-etcher.zip ${IMAGEPATH}/${NEW_VERSION_SERVER} ytl/ktp.img ktp.dd
fi

# Normal termination
exit 0
