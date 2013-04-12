#!/bin/sh

#  build-xbmc.sh
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
#  SYNOPSIS:
#  This script will download and install XBMC, starting with the XBMC
#  build tools.
#

BUILD_ERR=0
ERR_FILE_MISSING=1
ERR_GET_PREREQS_FAIL=2
ERR_GET_XBMC_FAIL=3
ERR_COMPILE_BT_FAIL=4
ERR_CONFIG_XBMC_FAIL=5
ERR_COMPILE_XBMC_FAIL=6
ERR_INSTALL_XBMC_FAIL=7

# Prints error messages.
print_error() {
    echo
    echo "\"$1\". Error returned: \"$2\"."
    echo
}

# The main routine.
main() {
    echo
    echo "Checking for required components..."
    cd /home/pi/xbmc_install

# Check to make sure all the scripts we need are present.
    if [ ! -f "get_platform_prereqs.sh" ]; then
        echo "ERROR: Missing component: get_platform_prereqs.sh."
        return $ERR_FILE_MISSING
    fi

	if [ ! -f "build_and_install_libcec.sh" ]; then
		echo "ERROR: Missing component: build_and_install_libcec.sh"
		return $ERR_FILE_MISSING
	fi

    if [ ! -f "copy_includes.sh" ]; then
        echo "ERROR: Missing component: copy_includes.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "create_symlinks.sh" ]; then
        echo "ERROR: Missing component: create_symlinks.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "get_xbmc.sh" ]; then
        echo "ERROR: Missing component: get_xbmc.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "compile_xbmc_buildtools.sh" ]; then
        echo "ERROR: Missing component: compile_xbmc_buildtools.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "configure_xbmc.sh" ]; then
        echo "ERROR: Missing component: configure_xbmc.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "compile_xbmc.sh" ]; then
        echo "ERROR: Missing component: compile_xbmc.sh"
        return $ERR_FILE_MISSING
    fi

    if [ ! -f "install_xbmc.sh" ]; then
        echo "ERROR: Missing component: install_xbmc.sh"
        return $ERR_FILE_MISSING
    fi

# Run all the build scripts and check the results.
    ./get_platform_prereqs.sh
    if [ $? -ne 0 ]; then
        return $ERR_GET_PREREQS_FAIL
    fi

	./build_and_install_libcec.sh
	if [ $? -ne 0 ]; then
		return $ERR_GET_PREREQS_FAIL
	fi

    ./copy_includes.sh
    ./create_symlinks.sh
    ./get_xbmc.sh
    if [ $? -ne 0 ]; then
        return $ERR_GET_XBMC_FAIL
    fi

    ./compile_xbmc_buildtools.sh
    if [ $? -ne 0 ]; then
        return $ERR_COMPILE_BT_FAIL
    fi

    ./configure_xbmc.sh
    if [ $? -ne 0 ]; then
        return $ERR_CONFIG_XBMC_FAIL
    fi

    ./compile_xbmc.sh
    if [ $? -ne 0 ]; then
        return $ERR_COMPILE_XBMC_FAIL
    fi

    ./install_xbmc.sh
    if [ $? -ne 0 ]; then
        return $ERR_INSTALL_XBMC_FAIL
    fi
	return 0
}

# Kickstart this thing. Verify with the user that we can proceed.
# Its gonna be a long haul!! Like 13 hours or so...
clear
echo "************* XBMC Installer v1.0 **************"
echo
echo "WARNING!! This process will take SEVERAL hours (~ 13) to complete!"

check_proceed() {
	local result=''
	while true; do
    	read -p "Are you sure you want to continue? (Y/n): " result
		case $result in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Check to see if we can reboot.
check_can_reboot() {
	local canreboot=''
	while true; do
		read -p "Reboot now (Y/n)?: " canreboot
		case $canreboot in
			[Yy]* ) return 0;;
			[Nn]* ) return 1;;
			* ) echo "Please answer yes or no.";;
		esac
	done
}

# Try check to see if we can proceed with the build.
# If build/install was a sucess, check to see if we're allowed to reboot.
if check_proceed; then
	main
	BUILD_ERR=$?
fi

if [ $BUILD_ERR -ne 0 ]; then
    print_error "Failed to build and install XBMC." $BUILD_ERR
else
    echo
    echo "You should reboot to complete the installation. Afterward, make sure"
	echo "to run the configure_htpc_platform.sh script in the CyrusBuiltHTPC"
	echo "package directory."
    if check_can_reboot; then
		exec /usr/bin/systemreboot
	else
		cd ~/
    fi
fi
exit $BUILD_ERR


