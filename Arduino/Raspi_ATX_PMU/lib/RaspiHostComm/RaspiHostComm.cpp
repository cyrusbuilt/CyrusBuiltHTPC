/*
 * RaspiHostComm.cpp - Soft RS232 communication library for CyrusBuiltHTPC (Arduino)
 * for host communication with a Raspiberry Pi.
 * v1.0
 *
 * Author:
 * Chris Brunner <cyrusbuilt at gmail dot com>
 *
 * Copyright (c) 2013 CyrusBuilt
 *
 * This program is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
 */

#include <RaspiHostComm.h>

RaspiHostCommClass::RaspiHostCommClass() {
    this->initialized = false;
}

RaspiHostCommClass::~RaspiHostCommClass() {
    // Shutdown the serial port and destroy it.
    if (this->hostComm != NULL) {
        this->hostComm.end();
        this->hostComm.~SoftwareSerial();
    }
    delete this->currentCommand;
    this->initialized = false;
}

void RaspiHostCommClass::begin(short rxPin, short txPin, void (*onCmdReceived)(PMUCommandInfo* sender), void (*onAck)(PMUCommandInfo* sender)) {
    // Initialize the serial port.
    this->hostComm = SoftwareSerial::SoftwareSerial(rxPin, txPin);
    this->hostComm.begin(SOFT_BAUD_RATE);
    // Wire up the pins and event handlers.
    this->currentCommand->rxPin = rxPin;
    this->currentCommand->txPin = txPin;
    this->currentCommand->onCmdReceived = onCmdReceived;
    this->currentCommand->onAck = onAck;
    this->initialized = true;
}

void RaspiHostCommClass::loop() {
    if (!this->initialized) {
        return;
    }

    // If we've received data from the serial port, read and decode the command.
    char cmd[CMD_BYTE_COUNT];
    while (this->hostComm.available()) {
        for (byte i = 0; i < CMD_BYTE_COUNT; i++) {
            cmd[i] = this->hostComm.read();
            if (cmd[i] == CMD_TERMINATOR) {
                break;
            }
        }

        switch (cmd[0]) {
            case PMUCommand_FORCE_PSU_OFF:
            case PMUCommand_FORCE_PSU_RESET:
            case PMUCommand_FW_SOFT_RESET:
            case PMUCommand_GETSTATUS:
                // Upon receiving a valid command, acknowledge that we
                // we received it, then fire the command received event.
                this->currentCommand->commandType = PMUCommand_ACK;
                this->currentCommand->onAck(this->currentCommand);
                delay(1000);
                this->currentCommand->commandType = (PMUCommands)val;
                this->currentCommand->onCmdReceived(this->currentCommand);
                break;
        }
    }

    delete[] cmd;
}

void RaspiHostCommClass::println(char* line) {
    if (this->initialized) {
        this->hostComm.println(line);
    }
}

RaspiHostCommClass RaspiHostComm;
