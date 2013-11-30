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

import io
import serial
import time


class SerialClientComm:
    ''' Handles communication between the RPi and the PMU via RS232. '''

    def __init__(self):
        ''' Class contructor '''
        self.baudRate = 115200
        self.delay = 0.5
        self.isOpen = False
        self.comm = None
        self.sio = None
        self.isDestroyed = False

    def begin(self):
        ''' Opens the serial port and initiates comunication with the PMU. '''
        if not self.isOpen:
            self.comm = serial.Serial('/dev/ttyAMA0', self.baudRate)
            self.sio = io.TextIOWrapper(io.BufferedRWPair(self.comm, self.comm))
            self.isOpen = True
        return

    def serialRead(self):
        ''' Reads commands from the serial port. '''
        self.begin()
        time.sleep(self.delay)
        result = None
        val = None
        remaining = 0
        while True:
            val = self.comm.read()
            time.sleep(1)
            remaining = self.comm.inWaiting()
            if remaining == 0:
                break
            else:
                val += self.comm.read(remaining)

        result = val.decode("utf-8").strip()
        return result

    def ackReceived(self):
        ''' Gets whether or not the PMU acknowledged the command. '''
        self.begin()
        time.sleep(self.delay)
        result = False
        val = None
        remaining = 0
        while True:
            val = self.comm.read()
            time.sleep(1)
            remaining = self.comm.inWaiting()
            if remaining > 0:
                if int.from_bytes(val, 'little') == 0:
                    val = self.comm.read()
                    if val.decode("utf-8").strip() == '\n':
                        result = True
                        break
        return result

    def serialWrite(self, command):
        ''' Writes a command to the serial port. '''
        self.begin()
        time.sleep(self.delay)
        cmd = command + str("\n")
        self.sio.write(cmd.encode())
        self.sio.flush()
        return

    def end(self):
        ''' Ends serial communication and closes the port. '''
        if self.isOpen:
            self.comm.close()
            self.isOpen = False
        return

    def __del__(self):
        ''' Class destructor '''
        if not self.isDestroyed:
            self.end()
            self.comm = None
            self.sio = None
            self.isDestroyed = True