#!/bin/sh

#  configure_htpc_platform.sh
#  
#
#  Created by Cyrus on 2/25/13.
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
#  SYNOPSIS: Configures the CyrusBuilt HTPC Platform.
#

# Check to see if the user wants to install AutoFS, which automounts filesystems
# on inserted drives and/or network filesystems (NFS, CiFS, SMB, etc).
check_install_autofs() {
	echo
	local canproceed
	while true; do
		read -p "Would you like me to install and configure AutoFS for you? (Y/n): " canproceed
		case $canproceed in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Check to see if the user wants to backup the local system configs prior to
# installing the new ones.
check_backup_configs() {
	echo
	local canbackup
	echo "WARNING:"
	echo "About to install custom system configs. This will replace rc.local, sudoers, modules,"
	echo "fstab, and config.txt. In doing so, the system will be overclocked to 800MHz and the"
	echo "GPU Mem scheme will be modified to 128MB (necessary for proper performance and compatibility"
	echo "for XBMC. This will also allow for an external hard disk or thumb drive (USB) to be"
	echo "mounted during startup (must be EXT4-formatted), as well as load and start the real-time"
	echo "clock (if connected) during boot."
	echo
	echo "It is recommended you back up your current system configs prior to proceeding."
	while true; do
		read -p "Backup system configs now? (Y/n): " canbackup
		case $canbackup in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "please answer yes or no.";;
		esac
	done
}

echo
echo
echo "Configuring CyrusBuilt HTPC Platform..."
# These are required for the RTC to function.
sudo apt-get install upower pm-utils i2c-utils

# If the user allows it, install AutoFS.
if check_install_autofs; then
	sudo apt-get install autofs
fi

# These are optional, but useful.
echo
echo "Installing optional packages ..."
sudo apt-get install gparted
sudo apt-get install scite jedit gkrellm    # This will also install open-jdk stuff.
sudo apt-get install htop ffmpeg
sudo apt-get install pidgin chromium

# Ask user to backup system configs.
if check_backup_configs; then
	./backup_configs.sh
fi

# Install all our custom configs.
echo
echo "Configuring HTPC platform..."
sudo cp xbmc-rpi /usr/bin/
sudo chown root:root /usr/bin/xbmc-rpi
sudo chmod +rx /usr/bin/xbmc-rpi
sudo cp config.txt /boot/
sudo chown root:root /boot/config.txt
sudo cp sudoers /etc/
sudo chown root:root /etc/sudoers
sudo cp rc.local /etc/
sudo chown /etc/rc.local
sudo chmod +rx /etc/rc.local
sudo cp modules /etc/
sudo chown /etc/modules
sudo cp fstab /etc/
sudo chown /etc/fstab

# Required for XBMC to have the authority to shutdown/reboot the system.
sudo cp "20-xbmclive.pkla" "/var/lib/polkit-1/localauthority/50-local.d/"
sudo chown "/var/lib/polkit-1/localauthority/50-local.d/20-xbmclive.pkla"

# Get rid of all the unnecessary shit. These are probably not present, but just
# to be on the safe side...
echo "Removing unneeded packages..."
echo
sudo apt-get purge exim4 exim4-base exim4-config exim4-daemon-light

# Turn off swap.
echo
echo "Disabling swap..."
sudo dphys-swapfile swapoff
echo
echo "Configuration finished."

# Check to see if we can reboot.
check_can_reboot() {
	local canreboot
	while true; do
		read -p "Reboot now (Y/n)?: " canreboot
		case $canreboot in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

echo
echo "You must reboot for the configuration to take effect."
if check_can_reboot; then
	exec /usr/bin/systemreboot
else
	cd ~/
fi
exit 0
