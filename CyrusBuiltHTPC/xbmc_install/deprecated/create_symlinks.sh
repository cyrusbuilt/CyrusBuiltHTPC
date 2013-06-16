#!/bin/sh

#  create_symlinks.sh
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
#  SYNOPSIS: Create symlinks for libEGL and libEGLSv2.
#

echo
echo "Creating necessary symlnks for libEGL and libEGLSv2 ..."

# If some of the libEGL or libGLESv2 symlinks point to a relative path, as for
# libEGL.so.1 and libGLESv2.so.2, the VC libraries won't be picked up. To fix
# the issue, rather than overwriting these links all the time, the actual
# binaries can be moved away, and replaced by links.
sudo mv /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0 /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0.orig
sudo ln -sf /opt/vc/lib/libGLESv2.so /usr/lib/arm-linux-gnueabihf/libGLESv2.so.2.0.0
sudo mv /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0 /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0.orig
sudo ln -sf /opt/vc/lib/libEGL.so /usr/lib/arm-linux-gnueabihf/libEGL.so.1.0
exit 0