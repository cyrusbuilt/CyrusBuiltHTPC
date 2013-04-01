#!/bin/sh

#  get_xbmc.sh
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
#  SYNOPSIS: Downloads XBMC using git.
#

# Blow away the local source from git, if it exists.
LOCAL_GIT_SRC="/home/pi/xbmc_install/xbmc-rbp"
if [ -d $LOCAL_GIT_SRC ]; then
    echo "Removing $LOCAL_GIT_SRC ..."
    rm -r -f $LOCAL_GIT_SRC
fi

# Get XBMC.
echo
echo "Cloning XBMC source from GIT repository..."
git clone --depth 1 git://github.com/xbmc/xbmc-rbp.git
if [ $? -ne 0 ]; then
    exit 1
fi
exit 0


