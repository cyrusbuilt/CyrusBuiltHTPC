#!/bin/sh

#  install_sys_tools.sh
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
#  SYNOPSIS: Installs the CyrusBuilt HTPC system tools.
#

echo
echo "Installing CyrusBuilt HTPC system tools..."
sudo cp systemreboot /usr/bin/
sudo cp systemshutdown /usr/bin/
sudo cp systemupdate /usr/bin/
cp backup_configs.sh ~/
cp restore_configs.sh ~/
sudo chmod +rx /usr/bin/systemreboot
sudo chmod +rx /usr/bin/systemshutdown
sudo chmod +rx /usr/bin/systemupdate
chmod +rx ~/backup_configs.sh
chmod +rx ~/restore_configs.sh
cd ~/CyrusBuiltHTPC/xbmc_install
chmod +rx *.sh

cd ~/
echo "Installation successful!"
exit 0
