#!/bin/sh

#  package_cleanup.sh
#
#
#  Created by Cyrus on 12/7/15.
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
#  SYNOPSIS: Cleanup the apt package database.
#

echo
echo "Cleaning up package database..."
echo
sudo apt-get install -f
sudo dpkg --configure -a
sudo apt-get clean
sudo apt-get update
exit 0