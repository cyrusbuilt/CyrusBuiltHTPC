/*
	PMUState.cpp - CyrusBuilt Raspi ATX PMU system states.CyrusBuilt Raspi ATX PMU system states.
*/

#include "PMUState.h"

const int PMUStateClass::ON = 1;
const int PMUStateClass::OFF = 0;
const int PMUStateClass::RESETING = 2;

PMUStateClass::PMUStateClass() {
}

PMUStateClass PMUState;
