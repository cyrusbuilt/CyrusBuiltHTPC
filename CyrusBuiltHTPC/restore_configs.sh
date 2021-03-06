#!/bin/sh

#  restore_configs.sh
#  
#
#  Created by Cyrus on 3/28/13.
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
#  SYNOPSIS: Restores configuration backup created by backup_configs.sh.
#

# Checks to see if the user wants to remove the backup once its been restored.
check_remove_backup() {
	echo
	local canremove
	while true; do
		read -p "Do you wish to remove the backup? (Y/n)?" canremove
		case $canremove in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Make sure backup directory still exists.
echo
echo
echo "Restoring original system onfiguration..."
BACKUP_DIR=/home/pi/configs_backup
if [ ! -d $BACKUP_DIR ]; then
	echo "ERROR: Configuration backup not found. Cannot continue."
	exit 1
fi

# Make sure each file in the backup set exists. If so, restore the file to the
# original location. Otherwise, throw a warning.
target=""
files="config.txt" "sudoers" "rc.local" "modules" "fstab"
for f in $files; do
	if [ -f "$BACKUP_DIR/$f" ]; then
		if [ "$f" == "config.txt" ]; then
			target=/boot/
		else
			target=/etc/
		fi
		sudo cp -v $BACKUP_DIR/$f $target
	else
		echo "WARNING: File in backup set missing: $BACKUP_DIR/$f"
	fi
done
echo "Done!"

# Find out fi the user wants to remove the old backup set.
if check_remove_backup; then
	echo
	echo "Cleaning up..."
	rm -rf $BACKUP_DIR
fi

echo "Restoration complete."
exit 0
