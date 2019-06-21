#!/bin/bash

OS=$(cat /etc/os-release | grep ID=raspian)

if [ -n "$OS" ]; then

	git clone https://github.com/SpecTurrican/PI_BitCloud/tree/master/bitcloud_setup /root/bitcloud_setup/
	nohup /root/bitcloud_setup/install_bitcloud.sh >/root/bitcloud_setup/logfile_start.log 2>&1 &
	clear
	tail -f /root/bitcloud_setup/logfile_start.log

else

	echo "This script running only below raspian ... sorry !!!"
	echo " "
	echo "Visit https://www.raspberrypi.org/downloads/raspbian/ "

fi
