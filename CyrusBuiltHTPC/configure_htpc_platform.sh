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
	local canbackup
	echo
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
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Check to see if the user has installed an RTC module and would like to load support.
check_can_install_rtc() {
	local candortc
	while true; do
		read -p "Do you have an RTC (Real-Time Clock) module installed? (Y/n): " candortc
		case $candortc in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

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

# Check to see if we can relocate rootfs to an external drive.
check_can_relocate_rootfs() {
	local canrelocate
	echo "Would you like to relocate rootfs to an external drive at this time?"
	echo "BE ADVISED: You MUST have and EXT4-formatted drive already attached"
	echo "to a USB port. This script assumes /mnt/sda1.  If the device has not"
	echo "yet been mounted, then it will be mounted first."
	while true; do
		read -p "Relocate now (Y/n)?: " canrelocate
		case $canrelocate in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

echo
echo
echo "Configuring CyrusBuilt HTPC Platform ..."
echo

# Ask user to backup system configs.
if check_backup_configs; then
	/home/pi/./backup_configs.sh
fi

# If the user allows it, install RTC support.
cd /home/pi/CyrusBuiltHTPC
if check_can_install_rtc; then
	echo "Installing RTC dependencies ..."
	echo
	#These are required for the RTC to function.
	sudo apt-get install python-smbus upower pm-utils i2c-tools -y
	sudo cp modules /etc/
	sudo chown root:root /etc/modules

	# Add the 2 users we care about to the i2c group
	echo
	echo "Adjusting device group memberships..."
	sudo usermod -a -G i2c pi
	sudo usermod -a -G i2c root
fi

# If the user allows it, install AutoFS.
if check_install_autofs; then
	sudo apt-get install autofs -y
fi

# These are optional, but useful.
echo
echo "Installing optional packages ..."
echo
# This will also install open-jdk stuff.
sudo apt-get install rpi-update gparted pidgin chromium htop ffmpeg scite jedit gkrellm rsync -y

# Install all our custom configs.
echo
echo "Configuring HTPC platform..."
sudo cp config.txt /boot/
sudo chown root:root /boot/config.txt
sudo cp sudoers /etc/
sudo chown root:root /etc/sudoers
sudo cp rc.local /etc/
sudo chown root:root /etc/rc.local
sudo chmod +rx /etc/rc.local
sudo cp fstab /etc/
sudo chown root:root /etc/fstab

# TODO The following lines were used to install a startup script for
# XBMC that allowed XBMC to auto -start on boot and then cleanly
# return the shell on exit. The script does not properly return to
# shell since upgrading from XBMC to Kodi, but does properly start
# it up. However, the script should not be necessary anymore since
# we set ENABLED=1 in /etc/default/kodi.
#sudo cp xbmc-rpi /usr/bin/
#sudo chown root:root /usr/bin/xbmc-rpi
#sudo chmod +rx /usr/bin/xbmc-rpi

# Required for XBMC to have the authority to shutdown/reboot the system.
sudo cp -f "20-xbmclive.pkla" "/var/lib/polkit-1/localauthority/50-local.d/"
sudo chown root:root "/var/lib/polkit-1/localauthority/50-local.d/20-xbmclive.pkla"

# Get rid of all the unnecessary shit. These are probably not present, but just
# to be on the safe side...
echo
echo "Removing unneeded packages..."
echo
sudo apt-get purge exim4 exim4-base exim4-config exim4-daemon-light

# Turn off swap.
echo
echo "Disabling swap..."
sudo dphys-swapfile swapoff
echo
echo "Configuration finished."

# Prompt user to see if they want to relocate rootfs here?
if check_can_relocate_rootfs; then
	MOUNTPOINT=/mnt/sda1
	if [ ! -d $MOUNTPOINT ]; then
		echo "Creating mount point for sda1..."
		sudo mkdir $MOUNTPOINT
		sudo chown pi:pi $MOUNTPOINT
	fi

	# Try mounting the USB HDD. If successful, rsync rootfs to it,
	# then modify the boot configuration to point to the correct
	# location for stage 2.
	echo
	echo "Mounting drive..."
	sudo mount /dev/sda1 $MOUNTPOINT
	if [ $? -ne 0 ]; then
		echo
		echo "ERROR: Unable to mount /dev/sda1 to $MOUNTPOINT."
		echo "ERROR: Cannot relocate rootfs."
	else
		echo
		echo "RSYNC'ing rootfs to $MOUNTPOINT ..."
		echo
		sudo rsync -avxS / /mnt/sda1
		sudo cp cmdline.txt /boot/
		sudo chown root:root /boot/cmdline.txt
		sudo cp config.txt /boot/
		sudo chown root:root /boot/config.txt
	fi
fi

# Get rid of un-needed packages, then ask if we can reboot.
echo
echo "Package cleanup..."
sudo apt-get autoremove
sudo apt-get clean
echo
echo "You must reboot for the configuration to take effect."
if check_can_reboot; then
	systemreboot
else
	cd ~/
fi
exit 0
