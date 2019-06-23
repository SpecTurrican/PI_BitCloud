# PI_BitCloud

## Bitcloud for Raspberry Pi 2/3 (without GUI)

Needs:

+ ISO Raspbian Lite (https://www.raspberrypi.org/downloads/raspbian/)
+ Login as ROOT (start Raspberry Pi and login as 'pi' user... password is 'raspberry'... 'sudo su root')

You can execute the following install script. Just copy/paste and hit return.
```
wget -qO - https://raw.githubusercontent.com/SpecTurrican/PI_BitCloud/master/setup.sh | bash
```
The installation goes into the background. You can follow the installation with :
```
tail -f /root/PI_BitCloud/logfiles/start.log # 1. Phase "Prepar the system"
or
tail -f /root/PI_BitCloud/logfiles/make.log # 2. Phase "Compiling"
```
The installation takes about 4 hours.
The Raspberry Pi is restarted 2 times during the installation.
After the installation the following user and password is valid :
```
bitcloud
```
The first time you log in, you will be prompted to change your password. Please do this.

If everything worked out, you can retrieve the status with the following command :
```
sudo bitcloud-cli getinfo             # general information
sudo bitcloud-cli masternode status   # is the masternode running ?
sudo bitcloud-cli masternode count    # how much mastenode ?
sudo bitcloud-cli mnsync status       # returns the sync status
sudo bitcloud-cli help                # list of commands
```

## Have fun and thanks for your support :-)
