#!/bin/sh

#  setup.sh
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
#  SYNOPSIS: Sets up the CyrusBuilt HTPC platform.
#

clear

# Ask the user if we can perform a system update.
setupCanDoSystemUpdate() {
	echo
	echo
	local canDoSetup
	while true; do
		read -p "Run system update now? (Y/n): " canDoSetup
		case $canDoSetup in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Ask the user if we can go ahead and install XBMC.
setupCanDoXBMC() {
	echo
	echo
	echo "System update was successful."
	local candoxbmc
	while true; do
		read -p "Install XBMC now? (Y/n): " candoxbmc
		case $candoxbmc in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Do initial setup.
echo
echo "Setting up CyrusBuilt HTPC Platform..."
chmod +rx install_sys_tools.sh
chmod +rx configure_htpc_platform.sh
./install_sys_tools.sh
./package_cleanup.sh
echo
echo "Setup complete."
echo
echo "To download and install XBMC, navigate to:"
echo "~/CyrusBuiltHTPC/xbmc_install"
echo "and run get_and_install_xbmc.sh"
echo
echo
echo "Prior to installing XBMC, it is recommended that"
echo "you run 'systemupdate' in order to be sure you"
echo "have the latest core libraries and system firmware."
if setupCanDoSystemUpdate; then
	systemupdate
	if [ $? -eq 0 ]; then
		# System update was successful. Go ahead and install XBMC?
		if setupCanDoXBMC; then
			cd xbmc_install
			./get_and_install_xbmc.sh
		fi
	fi
fi
exit 0

