#!/usr/bin/env bash

# Downloads and unpacks Abitti (www.abitti.fi) disk images.
#
# This script is public domain.
#
# This script is not supported by Matriculation Examination Board of
# Finland. The download URLs may change without any notice. For
# supported tools see www.abitti.fi.


FLAVOUR=prod
if type 'md5sum' > /dev/null 2>&1; then
        MD5="md5sum --check --status"
else
        MD5="md5 -r"
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

download_and_check() {
	TAG=$1
	
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
		wget -c http://static.abitti.fi/usbimg/${FLAVOUR}/${VERSION}/${TAG}.zip.md5 # Linux
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
cd ${DEST}

download_and_check ktp
download_and_check koe

# Normal termination
exit 0
