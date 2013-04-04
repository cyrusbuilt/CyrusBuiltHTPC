/*
	PMUState.h - CyrusBuilt Raspi ATX PMU system states.
*/

#ifndef PMUState_h
#define PMUState_h

#if defined(ARDUINO) && ARDUINO >= 100
#include "Arduino.h"
#else
#include "WProgram.h"
#endif

class PMUStateClass {
	public:
		PMUStateClass();
		static const int ON;
		static const int OFF;
		static const int RESETING;
};

extern PMUStateClass PMUState;
#endif