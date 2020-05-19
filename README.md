# PI_BitCloud

## Bitcloud for Raspberry Pi 2/3 (without GUI) ... and Pi 4 works to :-)

Needs:

+ ISO Raspbian Lite (https://www.raspberrypi.org/downloads/raspbian/)
+ Login as ROOT (start Raspberry Pi and login as 'pi' user... password is 'raspberry'... 'sudo su root')

You can execute the following install script. Just copy/paste and hit return.
```
wget -qO - https://raw.githubusercontent.com/SpecTurrican/PI_BitCloud/master/setup.sh | bash
```
The installation goes into the background. You can follow the installation with :
```
tail -f /root/PI_BitCloud/logfiles/start.log  # 1. Phase "Prepar the system"

or

tail -f /root/PI_BitCloud/logfiles/make.log   # 2. Phase "Compiling"
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
## Configfile
The configfile for bitcloud is stored in:
```
/root/.bitcloud/bitcloud.conf
```
Settings during installation:
```
rpcuser=bitcloudpixxxxxxxxx                 # x=random
rpcpassword=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxx  # x=random
rpcallowip=127.0.0.1
port=8329
server=1
listen=1
daemon=1
logtimestamps=1
txindex=1
killdebugilldebug=1                         # no logfile ... safe your sd-card :-)

#############
# NODE LIST #
#############
addnode=add a node from https://chainz.cryptoid.info/btdx/api.dws?q=nodes list
...
```
## Security
- You have a Firewall or Router ? Please open the Port 8329 for your raspberry pi. Thanks!
- fail2ban is configured with 24 hours banntime. (https://www.fail2ban.org/wiki/index.php/Main_Page)
- ufw service open ports is 22 and 8329. (https://help.ubuntu.com/community/UFW)
## Infos about Bitcloud
[Homepage](https://bit-cloud.cc/) | [Source GitHub](https://github.com/LIMXTEC/Bitcloud) | [Blockchainexplorer](https://chainz.cryptoid.info/btdx/) | [Discord](https://discord.gg/kgWVGD2) | [Telegram](https://t.me/bitcloud_btdx) | [bitcointalk.org](https://bitcointalk.org/index.php?topic=2092583.0)

## Have fun and thanks for your support :-)
BDTX donate to :
```
BPJWiKtjmnWiQ7H4mPAUyFBeLZfudRv6i7
```
