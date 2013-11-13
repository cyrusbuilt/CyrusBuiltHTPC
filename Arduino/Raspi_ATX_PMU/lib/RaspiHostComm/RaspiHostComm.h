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

#ifndef RASPIHOSTCOMM_H
#define RASPIHOSTCOMM_H

#include "../SoftwareSerial/SoftwareSerial.h"

#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

// Soft RS232 BAUD rate. This is the connection back to the Pi for receiving commands.
#define SOFT_BAUD_RATE 115200

#define CMD_TERMINATOR '\n'
#define CMD_BYTE_COUNT 2

/**
 * @brief The PMUCommands enum. Defines possible PMU commands.
 */
enum PMUCommands
{
    PMUCommand_ACK = 0,               // Command acknowledged.
    PMUCommand_GETSTATUS = 1,         // Get PMU status.
    PMUCommand_FORCE_PSU_RESET = 2,   // Force power reset.
    PMUCommand_FORCE_PSU_OFF = 3,     // Force power off.
    PMUCommand_FW_SOFT_RESET = 4      // PMU soft-reset.
};

/**
 * @brief The PMUCommandInfo struct. Used for storing information about
 * command events.
 */
struct PMUCommandInfo
{
    short rxPin;                                      // Receive (RX) pin.
    short txPin;                                      // Transmit (TX) pin.
    PMUCommands commandType;                          // The command type.
    void (*onCmdReceived)(PMUCommandInfo* sender);    // The command receive event handler.
    void (*onAck)(PMUCommandInfo* sender);            // The command acknowledged event handler.
};

/**
 * @brief The RaspiHostCommClass class. This class handles serial communication
 * with the Raspberry Pi host.
 */
class RaspiHostCommClass
{
  public:
    /**
     * @brief RaspiHostCommClass Initializes a new instance of the RaspiHostComm
     * class. This is the default constructor.
     */
    RaspiHostCommClass();

    /**
     * @brief ~RaspiHostCommClass Class destructor.
     */
    ~RaspiHostCommClass();

    /**
     * @brief begin Begins soft serial communication with the host and registers
     * event handler methods.
     * @param rxPin The receive (RX) pin.
     * @param txPin The transmit (TX) pin.
     * @param onCmdReveived Method called when valid commands are received.
     * @param onAck When serial commands are received and acknowledged.
     */
    void begin(short rxPin, short txPin, void (*onCmdReceived)(PMUCommandInfo* sender), void (*onAck)(PMUCommandInfo* sender));

    /**
     * @brief loop Command read/process loop. Typically added to the main
     * 'loop()' function.
     */
    void loop();

    /**
     * @brief println Prints a line of text to the serial port.
     * @param line The line of text to print.
     */
    void println(char* line);

  private:
    SoftwareSerial hostComm;
    PMUCommandInfo* currentCommand;
    bool initialized;
};

// Global instance.
extern RaspiHostCommClass RaspiHostComm;

#endif // RASPIHOSTCOMM_H
