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
check_can_configure() {
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
configure_xbmc() {
	echo
	echo "Configuring XMBC ..."
	# The user that will be running XBMC needs to be a member of the 
	# following groups
	sudo addgroup --system input
	groups="audio video input dialout plugdev tty"
	for i in $groups; do
		sudo usermod -a -G $i pi
	done

	local PI_USERDATA='/home/pi/.xbmc/userdata'
	local ROOT_USERDATA='/home/root/.xbmc/userdata'
	if [ -d $PI_USERDATA ]; then
		rm -rf $PI_USERDATA
	fi

	if [ -d $ROOT_USERDATA ]; then
		sudo rm -rf $ROOT_USERDATA
	fi

	if [ ! -d $PI_USERDATA ]; then
		if [ ! -d '/home/pi/.xbmc' ]; then
			mkdir '/home/pi/.xbmc'
		fi
		mkdir $PI_USERDATA
	fi

	if [ -d '/home/root' ]; then
		if [ ! -d $ROOT_USERDATA ]; then
			if [ ! -d '/home/root/.xbmc' ]; then
				sudo mkdir '/home/root/.xbmc'
			fi
			sudo mkdir $ROOT_USERDATA
		fi
	fi

	# Configure Kodi to auto-start on boot.
	if [ -f '/etc/default/kodi' ]; then
		sed -i 's/ENABLED=0/ENABLED=1/' '/etc/default/kodi'
	fi

	# Substitute our settings (reduces CPU usage).
	cp -f advancedsettings.xml $PI_USERDATA
	chown pi:pi $PI_USERDATA/advancedsettings.xml
	if [ -d '/home/root' ]; then
		sudo cp -f advancedsettings.xml $ROOT_USERDATA
		sudo chown root:root $ROOT_USERDATA/advancedsettings.xml
	fi
}

# Check to see if a previous version of Kodi is installed.
is_package_installed() {
	PKG_OK=$(dpkg-query -W --showformat='${Status}\n' $1|grep "install ok installed")
	echo "Checking for $1: $PKG_OK"
	if [ "$PKG_OK" == "" ]; then
  		return 1
  	else
  		return 0
	fi
}

# Check for and remove any previous installation.
echo
echo "Checking if a previous version of Kodi is installed..."
echo
UNINST_PKGS="libplatform1 libcec3 kodi"
for j in $UNINST_PKGS; do
	if is_package_installed $j; then
		echo "Uninstalling package: $j"
		sudo dpkg -r $j -y
	fi
done

# Setup UDEV rules to grant Kodi ownership of input devices.
TARGET='/etc/udev/rules.d'
FILES='99-input.rules 10-permissions.rules'
for f in $FILES; do
	if [ -f $f ]; then
		sudo cp -f $f $TARGET
		sudo chown root:root $TARGET/$f
	fi
done

# NOTE The following repo from Michael Gorven is now deprecated.
# It has not been updated since 2013 and is not compatible with
# Raspbian "Jessie". Even if you are currently running "Wheezy",
# it should be upgraded to "Jessie" when the systemupdate script
# is called during setup.

# Add XBMC source repo.
#echo
#echo "Configuring XBMC source repo ..."
#TARGET='/etc/apt/sources.list.d'
#FILE='mene.list'
#if [ -f $FILE ]; then
#	sudo cp -f $FILE $TARGET
#	sudo chown root:root $TARGET/$FILE
#fi

# Get and install Kodi. Add auth key if needed.
echo
echo "Installing QT3 bindings for Python ..."
echo
#sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-key 5243CDED
#echo
sudo apt-get update
sudo apt-get install python-qt3 -y
#sudo apt-get install kodi -y
ERR=$?
if [ $ERR -ne 0 ]; then
	echo
	echo "ERROR: XBMC installation failed. Error code: $ERR"
	exit $ERR
fi

# Downloaded and extract the Kodi package for "Jessie" from gkreidl's repo.
wget http://steinerdatenbank.de/software/kodi-15-jessie.tar.gz
tar -xzf kodi-15-jessie.tar.gz
cd kodi-15-jessie

# Now install Kodi.
echo
echo "Installing Kodi ..."
echo
sudo ./install
ERR=$?
if [ $ERR -ne 0 ]; then
	echo
	echo "ERROR: XBMC installation failed. Error code: $ERR"
	exit $ERR
else
	# Install HDMI CEC support.
	sudo apt-get install libcec3 -y
fi

# Configure Kodi and then offer to configure the host platform for the user.
configure_xbmc
echo
echo
echo "Kodi installation complete. It is necessary to configure the platform"
echo "to enable the RTC, relocate rootfs, enable Kodi auto-start on boot, etc."
echo "Would you like to configure the HTPC platform now? If so, you will be"
echo "required to reboot when finished in order for the changes to take effect."
echo
if check_can_configure; then
	sh /home/pi/CyrusBuiltHTPC/configure_htpc_platform.sh
else
	cd ~/
fi
exit 0


