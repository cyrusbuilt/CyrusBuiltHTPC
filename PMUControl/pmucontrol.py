# -*- coding: utf-8 -*-

# PMUControl - a console application for interacting with CyrusBuiltHTPC
# ATX PMU firmware.
# Copyright (c) 2013 CyrusBuilt
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301 USA
#
# In addition, as a special exception, the copyright holders give
# permission to link the code of portions of this program with the OpenSSL
# library.
#
# You must obey the GNU General Public License in all respects for all of
# the code used other than OpenSSL. If you modify file(s) with this
# exception, you may extend this exception to your version of the file(s),
# but you are not obligated to do so. If you do not wish to do so, delete
# this exception statement from your version. If you delete this exception
# statement from all source files in the program, then also delete it here.

import argparse
import time
from serialclientcomm import SerialClientComm


CMD_GETSTATUS = "getstatus"
CMD_FORCE_PSU_RESET = "forcepsureset"
CMD_FORCE_PSU_OFF = "forcepsuoff"
CMD_SOFT_RESET = "softreset"

CMD_CODE_ACK = 0
CMD_CODE_GETSTATUS = 1
CMD_CODE_FORCE_PSU_RESET = 2
CMD_CODE_FORCE_PSU_OFF = 3
CMD_CODE_FW_SOFT_RESET = 4

ser = SerialClientComm()


def get_command_code(cmd):
    ''' Gets the code for the specified command. '''
    if cmd.lower() == CMD_GETSTATUS:
        return CMD_CODE_GETSTATUS
    elif cmd.lower() == CMD_FORCE_PSU_RESET:
        return CMD_CODE_FORCE_PSU_RESET
    elif cmd.lower() == CMD_FORCE_PSU_OFF:
        return CMD_CODE_FORCE_PSU_OFF
    elif cmd.lower() == CMD_SOFT_RESET:
        return CMD_CODE_FW_SOFT_RESET
    else:
        return -1


def do_command(cmd):
    ''' Executes the specified command. '''
    ser.begin()
    time.sleep(500)
    ser.serialWrite(get_command_code(cmd))
    time.sleep(100)
    if ser.ackReceived():
        print((ser.serialRead()))
    return


def exec_getstatus():
    ''' Gets the current status of the PSU and prints it to the console. '''
    do_command(CMD_GETSTATUS)
    return


def exec_psureset():
    ''' Force-resets (power-cycle) the PSU. '''
    do_command(CMD_FORCE_PSU_RESET)
    return


def exec_psuoff():
    ''' Forces powers off the PSU. '''
    do_command(CMD_FORCE_PSU_OFF)
    return


def exec_pmusoftreset():
    ''' Soft-resets the firmware. '''
    do_command(CMD_SOFT_RESET)
    return


def printusage():
    ''' '''
    return


def main():
    ''' Main execution routine. Parses the command line arguments and
        executes the specified command. '''
    parser = argparse.ArgumentParser()
    parser.add_argument("-cmd", "--command", help="Command to execute")
    args = parser.parse_args()

    if args.command == CMD_GETSTATUS:
        exec_getstatus()
    elif args.command == CMD_FORCE_PSU_RESET:
        exec_psureset()
    elif args.command == CMD_FORCE_PSU_OFF:
        exec_psuoff()
    elif args.command == CMD_SOFT_RESET:
        exec_pmusoftreset()
    else:
        printusage()


if __name__ == "__main__":
    main()