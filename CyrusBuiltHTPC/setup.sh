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
echo
echo "Setting up CyrusBuilt HTPC Platform..."
chmod +rx install_sys_tools.sh
chmod +rx configure_htpc_platform.sh
./install_sys_tools.sh
echo
echo "Setup complete."
echo
echo "To build and install XBMC, navigate to:"
echo "/home/pi/xbmc_install"
echo "and run build-and-install-xbmc.sh"
exit 0

