#!/bin/bash

if [[ $EUID -ne 0 ]]; then

	echo "This script must be run as root" 1>&2

else

OS=$(cat /etc/os-release | grep ID=raspbian)
GIT_URL="https://github.com/SpecTurrican/PI_BitCloud"
INSTALL_DIR="/root/PI_BitCloud/"
INSTALL_FILE="${INSTALL_DIR}bitcloud_setup/install_bitcloud.sh"
LOG_DIR="${INSTALL_DIR}logfiles/"
LOG_FILE="start.log"

apt-get -y update && apt-get -y install git

	if [ -n "$OS" ]; then

		cd /root/
		git clone ${GIT_URL}
		chmod 744 -R ${INSTALL_DIR}
		mkdir ${LOG_DIR}
		nohup ${INSTALL_FILE} >${LOG_DIR}${LOG_FILE} 2>&1 &
		clear
		tail -f ${LOG_DIR}${LOG_FILE}

	else

		echo "This script running only below raspian ... sorry !!!"
		echo " "
		echo "Visit https://www.raspberrypi.org/downloads/raspbian/ "

	fi

fi
