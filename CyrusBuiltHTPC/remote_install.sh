#!/bin/sh

#  remote_install.sh
#  
#
#  Created by Cyrus on 3/28/13.
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
#  SYNOPSIS: Copies the CyrusBuiltHTPC package to the home directory on
#  Raspberry Pi via SCP.
#

raspi_ip=''
username=''
default_username='pi'

# Get the IP address of the Pi.
get_raspi_ip() {
	read -p "Enter the hostname/IP Address of the Raspberry Pi (SSH must be running): " raspi_ip
	if [ -z "$raspi_ip" ]; then
		return 1
	else
		return 0
	fi
}

# Get the username to authenticate with.
get_username() {
	read -p "Enter the username to authenticate with the Raspberry Pi (or blank for default [pi]): " username
	if [ -z "$username" ]; then
		username=$default_username
	fi
	return 0
}

# Try to copy the package to the Pi.
echo
echo
if get_raspi_ip; then
	if get_username; then
		cd ..
		scp -r CyrusBuiltHTPC $username@$raspi_ip:/home/pi
		err=$?
		echo
		if [ "$err" -ne "0" ]; then
			echo "Failed to copy CyrusBuiltHTPC to /home/pi on $raspi_ip."
		else
			echo "Package installation complete."
		fi
		cd CyrusBuiltHTPC
		exit $err
	fi
else
	echo "No hostname/IP provided. Cannot continue."
fi

exit 1