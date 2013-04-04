//Board = Arduino Micro
#define ARDUINO 103
#define __AVR_ATmega32U4__
#define F_CPU 16000000L
#define __AVR__
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
extern "C" void __cxa_pure_virtual() {}

void onPwrDown(ButtonInformation* sender);
void onPwrUp(ButtonInformation* sender);
void onPwrHold(ButtonInformation* sender);
void onPwrDouble(ButtonInformation* sender);
void onRstDown(ButtonInformation* sender);
void onRstUp(ButtonInformation* sender);
void onRstHold(ButtonInformation* sender);
void onRstDouble(ButtonInformation* sender);
//already defined in arduno.h
//already defined in arduno.h
String getIOModeString(uint8_t mode);
String getStateString(int state);
void reportInit();

#include "C:\Program Files\arduino-1.0.3\hardware\arduino\variants\micro\pins_arduino.h" 
#include "C:\Program Files\arduino-1.0.3\hardware\arduino\cores\arduino\arduino.h"
#include "D:\dev\Arduino\Raspi_ATX_PMU\Raspi_ATX_PMU.ino"
