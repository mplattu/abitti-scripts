#!/bin/bash

# Get settings

MY_PATH=$(dirname $0)
MY_SETTINGS=${MY_PATH}/a2_createvm.env
if [ ! -f ${MY_SETTINGS} ]; then
	echo "Settings file ${MY_SETTINGS} is missing. Create your own based on the ${MY_SETTINGS}.sample"
	exit 1
fi
source ${MY_SETTINGS}

# Find active host IP

if [ -z "${HOST_IP}" ]; then
	echo -n "Host IP was not set in settings, detecting..."
	HOST_IP=$(ip route get 1 | awk '{print $(NF-2);exit}')
	echo "${HOST_IP}"
fi

if [ -z "${HOST_IP}" ]; then
	echo "Failed to get host IP"
	exit 1
fi

# Create ktp-jako/ with supervisor password

if [ ! -d ktp-jako ]; then
	mkdir ktp-jako
	echo "Created ktp-jako/"
fi

if [ ! -f ktp-jako/htpasswd ]; then
	if [ -z "${SUPERVISOR_USERNAME}" ]; then
		echo "You have to set SUPERVISOR_USERNAME in ${MY_SETTINGS}"
		exit 1
	fi

	if [ -z "${SUPERVISOR_PASSWORD}" ]; then
		echo "You have to set SUPERVISOR_PASSWORD in ${MY_SETTINGS}"
		exit 1
	fi

	echo ${SUPERVISOR_PASSWORD} | htpasswd -i -c ktp-jako/htpasswd "${SUPERVISOR_USERNAME}"
fi

# Get server DNS address and certificate

if [ ! -f create-certificate.sh ]; then
	wget https://static.abitti.fi/abitti-2-test/app/create-certificate.sh
fi

if [ -f certs/domain.txt ]; then
	CHECK_HOST_NAME=$(cat certs/domain.txt)
	CHECK_HOST_IP=$(getent hosts ${CHECK_HOST_NAME} | cut -d " " -f1)

	if [ "${HOST_IP}" == "${CHECK_HOST_IP}" ]; then
		echo "Existing ${CHECK_HOST_NAME} appears to be valid"
	else
		echo "Host IP: ${HOST_IP}, but existing name ${CHECK_HOST_NAME} points to ${CHECK_HOST_IP}"
		rm -f certs/domain.txt
	fi
fi

if [ ! -f certs/domain.txt ]; then
	if [ -z "${API_KEY}" ]; then
		echo "You have to set API_KEY in ${MY_SETTINGS}"
		exit 1
	fi

	echo "Starting query for server address and certificate..."
	HOST_IP=$HOST_IP API_KEY=$API_KEY sh ./create-certificate.sh
	echo "...finished query for server address and certificate"
fi

if [ ! -f certs/domain.txt ]; then
	echo "Could not get server address & certificate"
	exit 1
fi

HOST_NAME=$(cat certs/domain.txt)

# Get docker-compose for the desired version

if [ -z "${ABITTI_VERSION}" ]; then
	echo "You have to set ABITTI_VERSION in ${MY_SETTINGS}"
	exit 1
fi

DOCKERFILE=docker-compose.prod.v${ABITTI_VERSION}.yml

if [ ! -f ${DOCKERFILE} ]; then
	wget https://static.abitti.fi/naksu2/${DOCKERFILE}
fi

# Log in to AWS ECR

curl -s https://oma.abitti.fi/digabi2/ecr-credentials | jq -r '.password' | docker login -u AWS --password-stdin https://863419159770.dkr.ecr.eu-north-1.amazonaws.com

zenity --info --text="Starting A2 server ${ABITTI_VERSION} at <a href=\"https://${HOST_NAME}\">${HOST_NAME}</a>" &

# Finally - profit!

HOST_NAME=$HOST_NAME docker compose -f ${DOCKERFILE} up --force-recreate --renew-anon-volumes
