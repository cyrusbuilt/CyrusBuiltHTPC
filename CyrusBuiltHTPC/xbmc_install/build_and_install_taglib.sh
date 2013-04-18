#!/bin/sh

#  build_and_install_taglib.sh
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
#  SYNOPSIS: Build and installs taglib.
#

echo
echo "Building and installing taglib...."
echo
TAGLIB_SOURCE=/home/pi/CyrusBuiltHTPC/xbmc_install/xbmc-rbp/xbmc-12.1/lib
cd $TAGLIB_SOURCE
make -C taglib
sudo make -C taglib install
err=$?
cd /home/pi/CyrusBuiltHTPC/xbmc_install
exit $err
