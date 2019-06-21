#!/bin/bash

# BASICS
COIN="bitcloud"
COIN_PORT="8329"
COIN_DOWNLOAD="https://github.com/LIMXTEC/Bitcloud"
COIN_BLOCKCHAIN_VERSION="Blockchain-01-09-2019"
COIN_BLOCKCHAIN="https://github.com/LIMXTEC/Bitcloud/releases/download/2.1.0.1.1/${COIN_BLOCKCHAIN_VERSION}.zip"
COIN_NODE="80.211.108.124"
COIND="/usr/local/bin/${COIN}d"
COIN_CLI="/usr/local/bin/${COIN}-cli"
COIN_BLOCKEXPLORER="https://chainz.cryptoid.info/btdx/api.dws?q=getblockcount"

# DIRS
ROOT="/root/"
INSTALL_DIR="${ROOT}PI_BitCloud/"
COIN_ROOT="${ROOT}.${COIN}"
COIN_INSTALL="${ROOT}${COIN}"
BDB_PREFIX="${COIN_INSTALL}/db4"

# DB
DB_VERSION="4.8.30"
DB_FILE="db-${DB_VERSION}.NC.tar.gz"
DB_DOWNLOAD="http://download.oracle.com/berkeley-db/${DB_FILE}"

# LIBRARIES and DEV_TOOLS
SSL_VERSION="1.0"
LIBRARIES="libssl${SSL_VERSION}-dev libboost-all-dev libevent-dev libminiupnpc-dev"
DEV_TOOLS="build-essential libtool autotools-dev autoconf cmake pkg-config bsdmainutils git libzmq3-dev unzip fail2ban ufw"

# Wallet RPC user and password
rrpcuser="${COIN}pi$(shuf -i 100000000-199999999 -n 1)"
rrpcpassword="$(shuf -i 1000000000-3999999999 -n 1)$(shuf -i 1000000000-3999999999 -n 1)$(shuf -i 1000000000-3999999999 -n 1)"

# User for System
ssuser="${COIN}"
sspassword="${COIN}"

# Install Script
SCRIPT_DIR="${INSTALL_DIR}${COIN}_setup/"
SCRIPT_NAME="install_${COIN}.sh"

# Logfile
LOG_DIR="${INSTALL_DIR}logfiles/"
LOG_FILE="make.log"

# System Settings
checkForRaspbian=$(cat /proc/cpuinfo | grep 'Revision')
CPU_CORE=$(cat /proc/cpuinfo | grep processor | wc -l)

start () {

	#
	# Welcome

	echo "*** Welcome to the ${COIN}world ***"
	echo ""
	echo ""
	echo "Please wait... now configuration the system!"

	# Put here for startup config
	/usr/bin/touch ${SCRIPT_LOG}
	/usr/bin/touch /boot/ssh
	sleep 5


}


app_install () {

	#
	# Install Tools

	apt-get update && apt-get upgrade -y
	apt-get install -y ${DEV_TOOLS} ${LIBRARIES}


}


manage_swap () {

	#
	# Some vendors already have swap set up, so only create it if it's not already there.

	exists="$(swapon --show | grep 'partition')"

	if [ -z "$exists" ]; then

		# https://www.2daygeek.com/shell-script-create-add-extend-swap-space-linux/#

		newswapsize=1024

		grep -q "swapfile" /etc/fstab

		if [ $? -ne 0 ]; then

			fallocate -l ${newswapsize}M /swapfile

			chmod 600 /swapfile

			mkswap /swapfile

			swapon /swapfile

			echo '/swapfile none swap defaults 0 0' >> /etc/fstab

		fi

	fi

	# On a Raspberry Pi 3, the default swap is 100MB. This is a little restrictive, so we are
	# expanding it to a full 1GB of swap.

	if [ ! -z "$checkForRaspbian" ]; then

	sed -i 's/CONF_SWAPSIZE=100/CONF_SWAPSIZE=1024/' /etc/dphys-swapfile

	fi


}


reduce_gpu_mem () {

	#
	# On the Pi, the default amount of gpu memory is set to be used with the GUI build. Instead
	# we are going to set the amount of gpu memmory to a minimum due to the use of the Command
	# Line Interface (CLI) that we are using in this build. This means we don't have a GUI here,
	# we only use the CLI. So no need to allocate GPU ram to something that isn't being used. Let's
	# assign the param below to the minimum value in the /boot/config.txt file.

	if [ ! -z "$checkForRaspbian" ]; then

		# First, lets not assume that an entry doesn't already exist, so let's purge and preexisting
		# gpu_mem variables from the respective file.

		sed -i '/gpu_mem/d' /boot/config.txt

		# Now, let's append the variable and value to the end of the file.

		echo "gpu_mem=16" >> /boot/config.txt

		echo "GPU memory was reduced to 16MB on reboot."

	fi


}


disable_bluetooth () {

	if [ ! -z "$checkForRaspbian" ]; then

		# First, lets not assume that an entry doesn't already exist, so let's purge any preexisting
		# bluetooth variables from the respective file.

		sed -i '/pi3-disable-bt/d' /boot/config.txt

		# Now, let's append the variable and value to the end of the file.

		echo "dtoverlay=pi3-disable-bt" >> /boot/config.txt

		# Next, we remove the bluetooth package that was previously installed.

		apt-get remove pi-bluetooth -y

		echo "Bluetooth was uninstalled."

	fi


}


set_network () {

	ipaddr=$(ip route get 1 | awk '{print $NF;exit}')

	hhostname="$(COIN)$(shuf -i 100000000-999999999 -n 1)"

	echo $hhostname > /etc/hostname && hostname -F /etc/hostname

	echo $ipaddr $hhostname >> /etc/hosts

	echo "Your Hostname is now : ${hhostname} "


}


set_accounts () {

	#
	# We don't always know the condition of the host OS, so let's look for several possibilities.
	# This will disable the ability to log in directly as root.

	sed -i 's/PermitRootLogin yes/PermitRootLogin no/' /etc/ssh/sshd_config

	sed -i 's/PermitRootLogin without-password/PermitRootLogin no/' /etc/ssh/sshd_config

	# Set the new username and password

	adduser $ssuser --disabled-password --gecos ""

	echo "$ssuser:$sspassword" | chpasswd

	adduser $ssuser sudo

	# We only need to lock the Pi account if this is a Raspberry Pi. Otherwise, ignore this step.

	if [ ! -z "$checkForRaspbian" ]; then

		# Let's lock the pi user account, no need to delete it.

		usermod -L -e 1 pi

		echo "The 'pi' login was locked. Please log in with '$ssuser'. The password is '$sspassword'."

		sleep 5

	fi


}


prepair_system () {

	#
	# prepair the installation

	apt-get autoremove -y
	cd ${ROOT}
	git clone $COIN_DOWNLOAD $COIN_INSTALL && mkdir $BDB_PREFIX
	wget $DB_DOWNLOAD
	tar -xzvf $DB_FILE && rm $DB_FILE
	mkdir $COIN_ROOT
	wget $COIN_BLOCKCHAIN
	unzip ${COIN_BLOCKCHAIN_VERSION}.zip -d $COIN_ROOT && rm ${COIN_BLOCKCHAIN_VERSION}.zip

	chown -R root:root ${COIN_ROOT}


}


prepair_crontab () {

	#
	# prepair crontab for restart

	/usr/bin/crontab -u root -r
	/usr/bin/crontab -u root -l | { cat; echo "@reboot		${SCRIPT_DIR}${SCRIPT_NAME} >${LOG_DIR}${LOG_FILE} 2>&1"; } | crontab -


}


restart_pi () {

	#
	# restart the system

	/usr/bin/touch /boot/${COIN}setup

	echo "restarting ... "
	echo " "
	echo "!!!!!!!!!!!!!!!!!"
	echo "!!! New login !!!"
	echo "!!!!!!!!!!!!!!!!!"
	echo "User: ${ssuser}  Password: ${sspassword}"
	echo " "
	read -p "Press any key to rebooting... " -n1 -s && reboot


}


make_db () {

	#
	# make Berkeley DB

	cd ${ROOT}/db-${DB_VERSION}.NC/build_unix/
	../dist/configure --enable-cxx --disable-shared --with-pic --prefix=${BDB_PREFIX}
	if [ "$CPU_CORE" = "4" ]; then
		make -j2 && make install
	else
		make && make install
	fi


}


make_coin () {

	#
	# make the wallet (without gui)

	cd $COIN_INSTALL
	./autogen.sh
	./configure LDFLAGS="-L${BDB_PREFIX}/lib/" CPPFLAGS="-I${BDB_PREFIX}/include/" --without-gui --disable-dependency-tracking --enable-tests=no  CXXFLAGS="--param ggc-min-expand=1 --param ggc-min-heapsize=32768"
	if [ "$CPU_CORE" = "4" ]; then
		make -j2 && make install
	else
		make && make install
	fi


}


configure_coin_conf () {

	#
	# Set the coin config file .conf

	echo "

	rpcuser=${rrpcuser}
	rpcpassword=${rrpcpassword}
	rpcallowip=127.0.0.1
	port=${COIN_PORT}
	server=1
	listen=1
	daemon=1
	logtimestamps=1
	txindex=1
	addnode=${COIN_NODE}
	killdebugilldebug=1

" > ${COIN_ROOT}/${COIN}.conf

	chmod 660 ${COIN_ROOT}/*.conf


}


config_ufw () {

	#
	# Setup for Firewall UFW
	# The default port is COIN_PORT

	ufw logging on
	ufw allow 22/tcp
	ufw limit 22/tcp
	# COIN_PORT
	ufw allow ${COIN_PORT}/tcp
	ufw default deny incoming
	ufw default allow outgoing
	yes | ufw enable


}


config_fail2ban () {

	#
	# The default ban time for users on port 22 (SSH) is 10 minutes. Lets make this a full 24
	# hours that we will ban the IP address of the attacker. This is the tuning of the fail2ban
	# jail that was documented earlier in this file. The number 86400 is the number of seconds in
	# a 24 hour term.


	echo "

	[sshd]
	enabled	= true
	bantime = 86400
	banaction = ufw

	[sshd-ddos]
	enabled = true
	bantime = 86400
	banaction = ufw

	" > /etc/fail2ban/jail.d/defaults-debian.conf

	# Configure the fail2ban jail and set the frequency to 20 min and 3 polls.

	echo "

	#
	# SSH
	#

	[sshd]
	port		= ssh
	logpath		= %(sshd_log)s
	maxretry = 3

	[sshd-ddos]
	# This jail corresponds to the standard configuration in Fail2ban.
	port    = ssh
	logpath = %(sshd_log)s
	maxretry = 2

	" > /etc/fail2ban/jail.local

	service fail2ban start


}


swap_off () {

	#
	# swap off/disable for safe your SD-Card

	swapoff -a
	service dphys-swapfile stop
	systemctl disable dphys-swapfile


}


configure_service () {

	#
	# Set systemctl

	echo "

	[Unit]
	Description=${COIN} service
	After=network.target
	[Service]
	User=root
	Group=root
	Type=forking
	ExecStart=${COIND} -daemon -conf=${COIN_ROOT}/${COIN}.conf -datadir=${COIN_ROOT}
	ExecStop=${COIN_CLI} -conf=${COIN_ROOT}/${COIN}.conf -datadir=${COIN_ROOT} stop
	Restart=always
	PrivateTmp=true
	TimeoutStopSec=90s
	TimeoutStartSec=90s
	StartLimitInterval=180s
	StartLimitBurst=5
	[Install]
	WantedBy=multi-user.target

	" > /etc/systemd/system/${COIN}.service

	systemctl daemon-reload
	sleep 5
	systemctl start ${COIN}.service
	systemctl enable ${COIN}.service >/dev/null 2>&1


}


checkrunning () {

	#
	# Is the service running ?

	echo " ... waiting of ${COIN}.service ... please wait!..."

	while ! ${COIN_CLI} getinfo >/dev/null 2>&1; do
		sleep 5
		error=$(${COIN_CLI} getinfo 2>&1 | cut -d: -f4 | tr -d "}")
		echo " ... ${COIN}.service is on : ${error}"
		sleep 2
	done

	echo "${COIN}.service is running !"


}


watch_synch () {

	#
	# Watch synching the blockchain

	sleep 5

	set_blockhigh=$(curl ${COIN_BLOCKEXPLORER})
	echo "  The current blockhigh is now : ${set_blockhigh} ..."
	echo "  -----------------------------------------"

	while true; do

	get_blockhigh=$(${COIN_CLI} getblockcount)

	if [ "$get_blockhigh" -lt "$set_blockhigh" ]
	then
		echo "  ... This may take a long time please wait!..."
		echo "    Block is now: $get_blockhigh / $set_blockhigh"
		sleep 10
	else
		echo "      Complete!..."
		echo "    Block is now: $get_blockhigh / $set_blockhigh"
		echo " "
		sleep 30
		break
	fi
	done


}


finish () {

	#
	# We now write this empty file to the /boot dir. This file will persist after reboot so if
	# this script were to run again, it would abort because it would know it already ran sometime
	# in the past. This is another way to prevent a loop if something bad happens during the install
	# process. At least it will fail and the machine won't be looping a reboot/install over and
	# over. This helps if we have ot debug a problem in the future.

	/usr/bin/touch /boot/ssh
	/usr/bin/touch /boot/${COIN}service

	/usr/bin/crontab -u root -r

	chage -d 0 ${ssuser}

	echo " "
	echo "${COIN} is installed. Thanks for your support :-)"
	echo " "
	echo " "
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "!!! Please change the password !!!"
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "User: ${ssuser}  Password: ${sspassword}"
	echo " "
	read -p "Press any key to rebooting... " -n1 -s && reboot


}


	#
	# Is the service installed ?

if [ -f /boot/${COIN}service ]; then

	echo "Previous ${COIN} detected. Install aborted."

else

	if [ -f /boot/${COIN}setup ]; then

		make_db
		make_coin
		configure_coin_conf
		config_ufw
		config_fail2ban
		swap_off
		configure_service
		checkrunning
		watch_synch
		finish

	else

	echo "Starting installation now..."
	sleep 3
	clear

	start
	app_install
	manage_swap
	reduce_gpu_mem
	disable_bluetooth
	set_network
	set_accounts
	prepair_system
	prepair_crontab
	restart_pi

	fi

fi
