#!/usr/bin/env bash

# Downloads and unpacks Abitti (www.abitti.fi) disk images.
#
# This script is public domain.
#
# This script is not supported by Matriculation Examination Board of
# Finland. The download URLs may change without any notice. For
# supported tools see www.abitti.fi.

FLAVOUR=prod
MYTEMP=/tmp/abitti_dlimg

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

download_and_check() {
	TAG=$1
	TEMPFILE=${MYTEMP}/${TAG}-etcher.zip

	if [ ! -d ${MYTEMP} ]; then
		mkdir -p ${MYTEMP}
	fi
	
	if [ "$(uname)" == "Darwin" ]; then
		curl -o ${TEMPFILE} http://static.abitti.fi/etcher-usb/${TAG}-etcher.zip # Mac OSX
	else
		wget -O ${TEMPFILE} -c http://static.abitti.fi/etcher-usb/${TAG}-etcher.zip # Linux
	fi
	if [ $? -ne 0 ]; then
		report_error "Failed to download image '${TAG}': $?"
	fi
	
	# Test zip for errors
	unzip -t ${TEMPFILE}
	if [ $? -ne 0 ]; then
		report_error "ZIP ${TEMPFILE} is corrupted: $?"
	fi
	
	if [ -d ${MYTEMP}/zip ]; then
		rm -fR ${MYTEMP}/zip/
	fi
	
	unzip ${TEMPFILE} -d ${MYTEMP}/zip/
	if [ $? -ne 0 ]; then
		report_error "Failed to unzip image '${TAG}': $?"
	fi
	
	
	mv ${MYTEMP}/zip/ytl/${TAG}.img ${DEST}/${TAG}.dd
	
	# Remove temporary files
	rm -fR ${MYTEMP}
}


if [ "$(uname)" == "Darwin" ]; then
	VERSION=`curl http://static.abitti.fi/usbimg/${FLAVOUR}/latest.txt`
else
	VERSION=`wget http://static.abitti.fi/usbimg/${FLAVOUR}/latest.txt -q -O-`
fi

if [ "${VERSION}" = "" ]; then
	report_error "Could not get latest Abitti version for flavour '${FLAVOUR}'"
fi

echo "Latest Abitti version: ${VERSION}"

DEST=abitti.v${VERSION}

if [ -d ${DEST} ]; then
	report_error "Directory ${DEST} already exists"
fi

mkdir ${DEST}

download_and_check ktp
download_and_check koe

# Normal termination
exit 0
