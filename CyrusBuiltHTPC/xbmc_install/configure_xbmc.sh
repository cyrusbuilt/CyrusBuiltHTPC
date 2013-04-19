#!/bin/sh

#  configure_xbmc.sh
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
#  SYNOPSIS: Configures XBMC for compilation.
#

echo
echo "Configuring XBMC for compile ..."
cd xbmc-rbp/xbmc-12.1

# This *might* be required for XBMC to compile successfully so the that
# proprietary version of the libs get picked up. ONLY uncomment the following
# line if necessary. Otherwise, leave it the hell alone.
sudo apt-get remove libegl1-mesa-dev libgl1-mesa-dev libgles2-mesa-dev

./configure --prefix=/usr --build=arm-linux-gnueabihf --host=arm-linux-gnueabihf \
--localstatedir=/var/lib --with-platform=raspberry-pi --disable-gl --enable-gles \
--disable-x11 --disable-sdl --enable-ccache --enable-optimizations \
--enable-external-libraries --disable-goom --disable-hal --disable-pulse \
--disable-vaapi --disable-vdpau --disable-xrandr --disable-airplay \
--disable-alsa --enable-avahi --disable-libbluray --disable-dvdcss \
--disable-debug --disable-joystick --disable-mid --enable-nfs --disable-profiling \
--disable-projectm --enable-rsxs --enable-rtmp --disable-vaapi \
--disable-vdadecoder --disable-external-ffmpeg  --disable-optical-drive \
--enable-libcec --enable-player=omxplayer --disable-airtunes
if [ $? -ne 0 ]; then
	cd /home/pi/CyrusBuiltHTPC/xbmc_install
    exit 1
fi

sed -i 's/ifeq (1,1)/ifeq (0,1)/' tools/TexturePacker/Makefile
cd /home/pi/CyrusBuiltHTPC/xbmc_install
exit 0