#!/bin/sh

#  install_xbmc.sh
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
#  SYNOPSIS: Installs XBMC.
#

echo
echo "Installing XBMC ..."
cd xbmc-rbp/xbmc-12.1
sudo make install
if [ $? -ne 0 ]; then
	cd /home/pi/CyrusBuiltHTPC/xbmc_install
    exit 1
fi

# Remove PVR addon source folder if it exists.
cd /home/pi/CyrusBuiltHTPC/xbmc_install
CURDIR=`pwd`
PVR="$CURDIR/pvr"
if [ -d $PVR ]; then
	echo "Removing $PVR ..."
	rm -rf $PVR
fi

# Get PVR source. If successful, build and install.
echo
echo "Cloning XBMC PVR Addons from github..."
git clone --depth 5 git://github.com/opdenkamp/xbmc-pvr-addons.git
if [ $? -ne 0 ]; then
	echo "WARNING: Failed to retrieve PVR Addons."
else
	cd $PVR
	echo "Building and installing PVR Addons..."
	echo
	./bootstrap
	echo
	echo
	./configure --prefix=/usr/local --enable-addons-with-dependencies
	echo
	echo
	sudo make install
	cd $CURDIR
fi

# Remove XVDR source dir, if exists.
XVDR="$CURDIR/xvdr"
if [ -d $XVDR ]; then
	echo "Removing $XVDR ..."
	rm -rf $XVDR
fi

# Get XVDR source. If successful, build and install.
echo
echo "Cloning XBMC XVDR Addons from github..."
git clone git://github.com/pipelka/xbmc-addon-xvdr.git
if [ $? -ne 0 ]; then
	echo "WARNING: Failed to retrieve XVDR Addons."
else
	cd $XVDR
	echo "Building and installing XVDR Addons..."
	echo
	sh autogen.sh
	echo
	echo
	./configure --prefix=/usr/local
	echo
	echo
	sudo make install
fi
cd $CURDIR
exit 0