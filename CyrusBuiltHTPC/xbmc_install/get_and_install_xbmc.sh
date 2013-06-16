#!/bin/sh

#  get_xbmc.sh
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
#  SYNOPSIS: Downloads XBMC using git.
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

echo "Configuring XBMC source repo ..."
TARGET='/etc/apt/sources.list.d'
FILE='mene.list'
if [ ! -f  '$TARGET/$FILE']; then
	sudo cp -f $FILE $TARGET
	sudo chown root:root '$TARGET/$FILE'
fi

echo "Installing XBMC ..."
echo
sudo addgroup --system input
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
sudo apt-get update
sudo apt-get install xbmc
if [ $? -ne 0 ]; then
	echo
	echo "Configuring XMBC ..."
	PI_USERDATA='~/.xbmc/userdata'
	ROOT_USERDATA='~/root/.xbmc/userdata'
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
	
	echo
	echo
	echo "XBMC installation complete. It is necessary to configure the platform"
	echo "to enable the RTC, relocate rootfs, enable XBMC auto-start on boot, etc."
	echo "Would you like to configure the HTPC platform now? If so, you will be"
	echo "required to reboot when finished in order for the changes to take effect."
	echo
	if check_can_configure; then
		exec ~/CyrusBuiltHTPC/configure_htpc_platform.sh
	else
		cd ~/
	fi
fi
exit 0


