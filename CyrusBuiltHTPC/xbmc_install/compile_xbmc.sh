#!/bin/sh

#  compile_xbmc.sh
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
#  SYNOPSIS: Builds XBMC.
#

echo
echo "Building XBMC ..."
cd xbmc-rbp/xbmc-12.1

# Do some sed magic to fixup the makefiles.
sed -i 's/-msse2//' lib/libsquish/Makefile
sed -i 's/-DSQUISH_USE_SSE=2//' lib/libsquish/Makefile
sudo sed -i 's/#include "vchost_config.h"/#include "interface\/vmc_host\/linux\/vchost_config.h"/' /usr/include/interface/vmcs_host/vcgencmd.h
make
if [ $? -ne 0 ]; then
	cd /home/pi/CyrusBuiltHTPC/xbmc_install
    exit 1
fi
cd /home/pi/CyrusBuiltHTPC/xbmc_install
exit 0