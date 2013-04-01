#!/bin/sh

#  backup_configs.sh
#  
#
#  Created by Cyrus on 2/27/13.
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
#  SYNOPSIS: Backs up all the local custom system configs, in case we
#  need them later.
#

echo
echo
echo "Backing up custom system configs..."
cd /home/pi
CURRENT_DIR=`pwd`

# create the backup directory if it doesn't exist.
BACKUP_DIR=$CURRENT_DIR/configs_backup
if [ ! -d $BACKUP_DIR ]; then
	mkdir $BACKUP_DIR
fi

# dump the contents of the current directory.
if [ "$(ls -A $BACKUP_DIR)" ]; then
	rm -rf $BACKUP_DIR/*
fi

BACKUP_DIR=$BACKUP_DIR/
sudo cp /usr/bin/xbmc-rpi $BACKUP_DIR
sudo cp /boot/config.txt $BACKUP_DIR
sudo cp /etc/sudoers $BACKUP_DIR
sudo cp /etc/rc.local $BACKUP_DIR
sudo cp /etc/modules $BACKUP_DIR
sudo cp /etc/fstab $BACKUP_DIR
sudo cp /var/lib/polkit-1/localauthority/50-local.d/20-xbmclive.pkla $BACKUP_DIR
echo "Done!"
echo
echo "A backup copy of the configs are in $BACKUP_DIR"
exit 0