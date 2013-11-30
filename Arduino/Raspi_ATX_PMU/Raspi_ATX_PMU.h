/*
 Raspi_ATX_PMU
 v1.8b

 Author:
 Chris Brunner <cyrusbuilt at gmail dot com>

 Copyright (c) 2013 CyrusBuilt

 This program is free software; you can redistribute it and/or modify
 it under the terms of the GNU General Public License as published by
 the Free Software Foundation; either version 2 of the License, or
 (at your option) any later version.

 This program is distributed in the hope that it will be useful,
 but WITHOUT ANY WARRANTY; without even the implied warranty of
 MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 GNU General Public License for more details.

 You should have received a copy of the GNU General Public License
 along with this program; if not, write to the Free Software
 Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA

 IMPORTANT NOTE:
 This firmware is meant for the Arduino Micro/Uno
 Future versions will implement a HAL that will provide compatibility with
 other boards.  However, this may be compatible as-is with other boards,
 though it has not been tested.  This is *NOT* compatible with the
 ATtiny-series controllers.

 DEPENDENCIES:
 This firmware is dependent on the ebl-arduino event library.
 (http://code.google.com/p/ebl-arduino/) A copy of the library implemented
 by this firmware should be included with the source. You will need to
 install the library contents into your Arduino IDE's libraries folder
 in order to compile.

 This requires the PMUState library in the /lib folder for setting/checking
 the state of the PMU.

 This firmware is now dependent on DuinOS v0.4 Alpha (https://github.com/DuinOS/DuinOS).
 This enables this firmware to perform its functions as tasks within DuinOS, which
 implements a pre-emptive RTOS kernel.
 */


#ifndef Raspi_ATX_PMU_H_
#define Raspi_ATX_PMU_H_

// Board = Arduino Uno
#define __AVR_ATmega328p__
#define ARDUINO 103
#define __AVR__
#define F_CPU 16000000L
#define __cplusplus
#define __attribute__(x)
#define __inline__
#define __asm__(x)
#define __extension__
#define __ATTR_PURE__
#define __ATTR_CONST__
#define __inline__
#define __asm__
#define __volatile__
#define __builtin_va_list
#define __builtin_va_start
#define __builtin_va_end
#define __DOXYGEN__
#define prog_void
#define PGM_VOID_P int
#define NOINLINE __attribute__((noinline))

typedef unsigned char byte;
extern "C" void __cxa_pure_virtual() {;}

#ifdef __cplusplus
extern "C" {
#endif
void loop();
void setup();
#ifdef __cplusplus
} // extern "C"
#endif

String getStateString(int state);
void onPwrDown(ButtonInformation* sender);
void onPwrUp(ButtonInformation* sender);
void onPwrHold(ButtonInformation* sender);
void onPwrDouble(ButtonInformation* sender);
void onRstDown(ButtonInformation* sender);
void onRstUp(ButtonInformation* sender);
void onRstHold(ButtonInformation* sender);
void onRstDouble(ButtonInformation* sender);
void softReset();
void onCmdAcknowledged(PMUCommandInfo* sender);
void onCmdReceived(PMUCommandInfo* sender);
#ifdef DEBUG
String getIOModeString(uint8_t mode);
void reportInit();
#endif
//

#define DARWIN
//#define WIN32
//#define WIN64
//#define LINUX

#if defined(DARWIN)
#include "/Applications/Arduino.app/Contents/Resources/Java/hardware/arduino/variants/standard/pins_arduino.h"
#include "/Applications/Arduino.app/Contents/Resources/Java/hardware/arduino/cores/arduino/arduino.h"
#elif defined(WIN32)

#elif defined(WIN64)

#elif defined(LINUX)

#endif

#include "Raspi_ATX_PMU.ino"
#endif /* Raspi_ATX_PMU_H_ */

