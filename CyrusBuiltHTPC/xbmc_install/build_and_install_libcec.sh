#!/bin/sh

#  build_and_install_libcec.sh
#  
#
#  Created by Cyrus on 4/11/13.
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
#  SYNOPSIS: Downloads libCEC from github, then compiles and installs it.
#  This must be done *prior* to configuring/compiling xbmc in order to
#  enable libcec support (allows control of xbmc using your tv remote
#  by sending the commonds over HDMI).
#

# Get the dependencies.
sudo apt-get install libraspberrypi-dev

# Blow away the local source from git, if it exists.
LOCAL_LIB_SRC="/home/pi/CyrusBuiltHTPC/xbmc_install/libcec"
if [ -d $LOCAL_LIB_SRC ]; then
	echo "Removing $LOCAL_LIB_SRC ..."
	rm -rf $LOCAL_LIB_SRC
fi

# Get libCEC.
echo
echo "Cloning libCEC source from GIT repository..."
git clone --depth 1 git://github.com/Pulse-Eight/libcec.git
if [ $? -ne 0 ]; then
	exit 1
fi

cd $LOCAL_LIB_SRC
./bootstrap
echo
echo
./configure --with-rpi-lib-path="/opt/vc/lib" --with-rpi-include-path="/opt/vc/include"
echo
echo
make
echo
sudo make install
err=$?
cd /home/pi/CyrusBuiltHTPC/xbmc_install
exit $err