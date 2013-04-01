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
cd xbmc-rbp/
# This *might* be required for XBMC to compile successfully so the that
# proprietary version of the libs get picked up. ONLY uncomment the following
# line if necessary. Otherwise, leave it the hell alone.
 
# sudo apt-get remove libegl1-mesa-dev libgl1-mesa-dev libgles2-mesa-dev

# Do some sed magic to fixup the makefiles.
sed -i 's/-msse2//' lib/libsquish/Makefile
sed -i 's/-DSQUISH_USE_SSE=2//' lib/libsquish/Makefile
sudo sed -i '/#include "vchost_config.h"/#include "interface/vmcs_host/linux/vchost_config.h"/g' /usr/include/interface/vmcs_host/vgencmd.h
make
if [ $? -ne 0 ]; then
	cd /home/pi/xbmc_install
    exit 1
fi
cd /home/pi/xbmc_install
exit 0