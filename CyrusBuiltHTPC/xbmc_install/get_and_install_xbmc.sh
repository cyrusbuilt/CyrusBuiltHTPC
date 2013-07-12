#!/bin/sh

#  get_and_install_xbmc.sh
#  
#
#  Created by Cyrus on 2/24/13.
#
#  This program is free software; you can redistribute it and/or modify
#  it under the terms of the GNU General Public License as published by
#  the Free Software Foundation; either version 2 of the License, or
#  (at your option) any later version.
#
#  This program is distributed in the hope that it will be useful,
#  but WITHOUT ANY WARRANTY; without even the implied warranty of
#  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
#  GNU General Public License for more details.
#
#  You should have received a copy of the GNU General Public License
#  along with this program; if not, write to the Free Software
#  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
#
#  SYNOPSIS: Downloads and installs XBMC via APT, then configures it.
#  This should only be ran on Raspbian Wheezy (2012-10-28) or higher.
#  It would be a good idea to update the system (apt-get update) prior
#  to running this.
#

# Check to see if we can configure the HTPC platform.
function check_can_configure() {
	local canconfigure=''
	while true; do
		read -p "Configure platform now (Y/n)?: " canconfigure
		case $canconfigure in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Do post-install configuration.
function configure_xbmc() {
	echo
	echo "Configuring XMBC ..."
	local PI_USERDATA='~/.xbmc/userdata'
	local ROOT_USERDATA='~/root/.xbmc/userdata'
	if [ -d $PI_USERDATA ]; then
		rm -rf $PI_USERDATA
	fi
	
	if [ -d $ROOT_USERDATA ]; then
		sudo rm -rf $ROOT_USERDATA
	fi
	
	if [ ! -d $PI_USERDATA ]; then
		mkdir $PI_USERDATA
	fi
	
	if [ ! -d $ROOT_USERDATA ]; then
		sudo mkdir $ROOT_USERDATA
	fi
	
	cp -f advancedsettings.xml $PI_USERDATA
	chown pi:pi '$PI_USERDATA/advancedsettins.xml'
	sudo cp -f advancedsettings.xml $ROOT_USERDATA
	sudo chown root:root '$ROOT_USERDATA/advancedsettings.xml'
}

# And XBMC source repo.
echo "Configuring XBMC source repo ..."
TARGET='/etc/apt/sources.list.d'
FILE='mene.list'
if [ ! -f  '$TARGET/$FILE']; then
	sudo cp -f $FILE $TARGET
	sudo chown root:root '$TARGET/$FILE'
fi

# Get and install XBMC. Add auth key if needed.
echo "Installing XBMC ..."
echo
sudo addgroup --system input
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
sudo apt-get update
sudo apt-get install xbmc
ERR=$?
if [ $ERR -ne 0 ]; then
	echo
	echo "ERROR: XBMC installation failed. Error code: $ERR"
	exit $ERR 
fi

# Configure XBMC and then offer to configure the host platform for the user.
configure_xbmc
echo
echo
echo "XBMC installation complete. It is necessary to configure the platform"
echo "to enable the RTC, relocate rootfs, enable XBMC auto-start on boot, etc."
echo "Would you like to configure the HTPC platform now? If so, you will be"
echo "required to reboot when finished in order for the changes to take effect."
echo
if check_can_configure; then
	sh ~/CyrusBuiltHTPC/configure_htpc_platform.sh
else
	cd ~/
fi
exit 0


