// Only modify this file to include
// - function definitions (prototypes)
// - include files
// - extern variable definitions
// In the appropriate section

#ifndef Raspi_ATX_PMU_H_
#define Raspi_ATX_PMU_H_

// Board = Arduino Uno
#define __AVR_ATmega328P__
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

//add your includes for the project here


//end of add your includes here
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

