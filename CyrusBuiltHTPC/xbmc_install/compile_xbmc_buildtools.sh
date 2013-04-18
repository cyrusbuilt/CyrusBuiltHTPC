#!/bin/sh

#  compile_xbmc_buildtools.sh
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
#  SYNOPSIS: Compiles the XBMC build tools.
#

echo
echo "Compiling XBMC build tools ..."
cd xbmc-rbp/xbmc-12.1
export TARGET_SUBARCH="armv6zk"
export TARGET_CPU="arm1176jzf-s"
export TARGET_FLOAT="hard"
export TARGET_FPU="vfp"
export TARGET_FPU_FLAGS="-mfloat-abi=$TARGET_FLOAT -mfpu=$TARGET_FPU"
export TARGET_EXTRA_FLAGS="-Wno-psabi -Wa,-mno-warn-deprecated"
export TARGET_COPT="-Wall -pipe -fomit-frame-pointer -O3 -fexcess-precision=fast -ffast-math  -fgnu89-inline"
export TARGET_LOPT="-s -Wl,--as-needed"
export CFLAGS="-march=$TARGET_SUBARCH -mcpu=$TARGET_CPU $TARGET_FPU_FLAGS -mabi=aapcs-linux $TARGET_COPT $TARGET_EXTRA_FLAGS"
export CXXFLAGS="$CFLAGS"
export LDFLAGS="-march=$TARGET_SUBARCH -mtune=$TARGET_CPU $TARGET_LOPT"

# Fixup SDK setup script.
sed -i 's/USE_BUILDROOT=1/USE_BUILDROOT=0/' tools/rbp/setup-sdk.sh
sed -i 's/TOOLCHAIN=\/usr\/local\/bcm-gcc/TOOLCHAIN=\/usr/' tools/rbp/setup-sdk.sh
sudo sh tools/rbp/setup-sdk.sh

# Fixup make file, then compile the build tools.
sed -i 's/cd $(SOURCE); $(CONFIGURE)/#cd $(SOURCE); $(CONFIGURE)/' tools/rbp/depends/xbmc/Makefile
make -C tools/rbp/depends/xbmc/
if [ $? -ne 0 ]; then
	cd /home/pi/CyrusBuiltHTPC/xbmc_install
    exit 1
fi
cd /home/pi/CyrusBuiltHTPC/xbmc_install
exit 0