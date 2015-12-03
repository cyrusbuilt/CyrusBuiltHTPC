/*
 Raspi_ATX_PMU
 v2.0

 Author:
 Chris Brunner <cyrusbuilt at gmail dot com>

 Copyright (c) 2015 CyrusBuilt

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
 */

// Comment the following line to disable debug mode.
#define DEBUG 1

#include "Arduino.h"
#include "ButtonEvent.h"

// Workaround for http://gcc.gnu.org/bugzilla/show_bug.cgi?id=34734
#ifdef PROGMEM
#undef PROGMEM
#define PROGMEM __attribute__((section(".progmem.data")))
#endif

#define VERSION "Raspi_ATX_PMU V1.9b"

#ifdef DEBUG
#define DEBUG_BAUD_RATE 9600
// High and low (on/off) state strings.
String highStr = "ON";
String lowStr = "OFF";
bool msgPrinted = false;
#endif // DEBUG

// Pin definitions.
#define RST_BUTTON 4       // Reset button on pin 4.
#define RST_RELAY 12       // Reset relay on pin 12.
#define PWR_BUTTON 8       // Power button on pin 8.
#define LED 9              // LED on pin 9.
#define PWR_RELAY_12V 10   // Power relay on pin 10 (12V).
#define PWR_RELAY_5V 6     // Power relay on pin 6 (5V)
#define EXT_LED 11         // External (chassis) LED on pin 11.
#define SHUTDOWN_DETECT 5  // Shutdown detection on pin 5.
#define TRIGGER 7          // ATX Trigger on pin 7.

// Possible PMU states.
enum PMUState
{
  PMUState_ON = 1,
  PMUState_OFF = 0,
  PMUState_RESETTING = 2
};

// Configuration - ONLY TWEAK THESE SETTING IF YOU KNOW WHAT YOU ARE DOING!!!!
const int holdTime = 3000;                  // How long to wait to consider the reset button held down.
const int interval = 200;                   // The interval to check button state.
const int shutdownThreshold = 4000;         // The amount of time to wait to consider the RPi shut down.
const int shutdownDetectDelay = 500;        // The amount of time to delay shutdown detection.

// Local vars.
volatile int state = PMUState_OFF;          // The current system state.
volatile int stateOld = state;              // The old system state (used for comparison).
volatile int timeDown = 0;                  // The amount of time the RPi appears to have been down.
volatile bool shutdownDetection = true;

const uint8_t ALL_OUTPUTS[] = { PWR_RELAY_12V, PWR_RELAY_5V, EXT_LED, LED, RST_RELAY, TRIGGER };
const uint8_t ALL_RELAYS[] = { PWR_RELAY_5V, PWR_RELAY_12V };
const uint8_t ALL_LEDS[] = { LED, EXT_LED};


/**
 * @brief getStateString Gets the string representation of an output state.
 * @param state The PMU state.
 * @return The string representation of the state.
 */
String getStateString(int state) {
    String stateStr = "OFF";
    if (state == PMUState_ON) {
        stateStr = "ON";
    }
    else if (state == PMUState_RESETTING) {
        stateStr = "RESETING";
    }
    return stateStr;
}

/**
 * @brief initOutputs Initializes all outputs.
 */
void initOutputs() {
	for (uint8_t i = 0; i <= (sizeof(ALL_OUTPUTS) - 1); i++) {
		pinMode(ALL_OUTPUTS[i], OUTPUT);
	}
}

/**
 * @brief initSDdetector Initializes the shutdown detection pin.
 */
void initSDdetector() {
  // Set pin 5 as input and then enable internal pull-up resistor by driving it high.
  pinMode(SHUTDOWN_DETECT, INPUT);
  digitalWrite(SHUTDOWN_DETECT, HIGH);
}

/**
 * @brief setAllRelayStates Sets the state of all relays.
 * @param on Set true to turn all relays on; false to turn them off.
 */
void setAllRelayStates(bool on) {
	for (uint8_t i = 0; i <= (sizeof(ALL_RELAYS) - 1); i++) {
		if (on) {
			digitalWrite(ALL_RELAYS[i], HIGH);
		}
		else {
			digitalWrite(ALL_RELAYS[i], LOW);
		}
	}
}

/**
 * @brief setAllLedStates Sets the state of all LEDs.
 * @param on Set true to turn LEDs on; false to turn them off.
 */
void setAllLedStates(bool on) {
	for (uint8_t i = 0; i <= (sizeof(ALL_LEDS) - 1); i++) {
		if (on) {
			digitalWrite(ALL_LEDS[i], HIGH);
		}
		else {
			digitalWrite(ALL_LEDS[i], LOW);
		}
	}
}

/**
 * @brief setTriggerState Sets the state of the ATX trigger.
 * @param on Set true to engage ATX trigger; false to disengage.
 */
void setTriggerState(bool on) {
	if (on) {
		digitalWrite(TRIGGER, HIGH);
	}
	else {
		digitalWrite(TRIGGER, LOW);
	}
}

/**
 * @brief setAllOutputExceptTriggerStates Sets the state of all outputs, except
 * the ATX trigger.
 * @param on Set true to turn outputs on; false to turn them off.
 */
void setAllOutputExceptTriggerStates(bool on) {
	for (uint8_t i = 0; i <= (sizeof(ALL_OUTPUTS) - 1); i++) {
		if (ALL_OUTPUTS[i] != TRIGGER) {
			if (on) {
				digitalWrite(ALL_OUTPUTS[i], HIGH);
			}
			else {
				digitalWrite(ALL_OUTPUTS[i], LOW);
			}
		}
	}
}

/**
 * @brief suspendShutdownDetection Suspends detection of host shutdown.
 */
void suspendShutdownDetection() {
  shutdownDetection = false;
}

/**
 * @brief resumeShutdownDetection Resumes detection of host shutdown.
 */
void resumeShutdownDetection() {
  shutdownDetection = true;
}

/**
 * @brief onPwrDown Power button down event handler.
 * @param sender The sender event information.
 */
void onPwrDown(ButtonInformation* sender) {
  // Skip if we're in the middle of a reset.
  if (state == PMUState_RESETTING) {
    return;
  }

  // Get button value and compare current state to old state.
  if (int(sender->analogValue) == LOW) {
    return;
  }

  // Are we changing states?
  if (state == PMUState_ON) {
    state = PMUState_OFF;
  }
  else {
    state = PMUState_ON;
  }

  // Compare to previous state.
  if (state != stateOld) {
    // If state changed to 'ON', then turn power on; Otherwise, turn it off.
    if (state == PMUState_ON) {
      // Turn the ATX supply on first, then wait a little bit.
      setTriggerState(true);
      delay(50);

      // We should have the power to kick on the relays and LEDs now.
      setAllOutputExceptTriggerStates(true);

      // We have power now, so resume the shutdown detection task, but give the
      // RPi a few seconds to try and boot up first.
      delay(5000);
      resumeShutdownDetection();
    }
    else {
      // Kill the relays and LEDs.
      setAllOutputExceptTriggerStates(false);

      // Wait a little bit and then drop out the ATX power.
      delay(50);
      setTriggerState(false);
      suspendShutdownDetection();
    }

    stateOld = state;

#ifdef DEBUG
    String stateStr = getStateString(state);
    Serial.println("Input: Power Button. Event: Pressed. Action: " + stateStr);
    Serial.println("Output: Power Relay (12V). Action: " + stateStr);
    Serial.println("Output: Power Relay (5V).  Action: " + stateStr);
    Serial.println("Output: Status LED.        Action: " + stateStr);
    Serial.println("Output: Ext St LED.        Action: " + stateStr);
    Serial.println("Output: ATX Trigger.       Action: " + stateStr + "\n");
#endif // DEBUG
  }
}

/**
 * @brief onRstDown Reset button down event handler.
 * @param sender The sender event information.
 */
void onRstDown(ButtonInformation* sender) {
    if (int(sender->analogValue) == LOW) {
        return;
    }

    if (state == PMUState_ON) {
        suspendShutdownDetection();
        digitalWrite(RST_RELAY, HIGH);
        setAllLedStates(false);
        state = PMUState_RESETTING;

#if defined(DEBUG)
        String stateStr = getStateString(state);
        Serial.println("Input: Reset Button. Event: Pressed. Action: " + stateStr);
        Serial.println("Output: Reset Relay. Action: " + highStr);
        Serial.println("Output: Status LED.  Action: " + lowStr);
        Serial.println("Output: Ext St LED.  Action: " + lowStr);
        Serial.println("Output: ATX Trigger. Action: " + highStr + "\n");
#endif // DEBUG
    }
}

/**
 * @brief onRstUp Reset button up event hanlder.
 * @param sender The sender event information.
 */
void onRstUp(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  if (state == PMUState_RESETTING) {
    digitalWrite(RST_RELAY, LOW);
    setAllLedStates(true);
    state = PMUState_ON;
    resumeShutdownDetection();

#if defined(DEBUG)
    String stateStr = getStateString(state);
    Serial.println("Input: Reset Button. Event: Released. Action: " + stateStr);
    Serial.println("Output: Reset Relay. Action: " + lowStr);
    Serial.println("Output: Status LED.  Action: " + highStr);
    Serial.println("Output: Ext St LED.  Action: " + highStr);
    Serial.println("Output: ATX Trigger. Action: " + highStr + "\n");
#endif // DEBUG
  }
}

/**
 * @brief onRstHold Reset button hold event handler.
 * @param sender The sender event information.
 */
void onRstHold(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  // Just delay on hold. We don't want to finish the reset cycle until the
  // operator releases the button.
  if (state == PMUState_RESETTING) {
#ifdef DEBUG
    Serial.println(F("Input: Reset Button. Event: Hold. Action: None."));
    Serial.println("Output: Reset Relay. Action: " + highStr + "\t(holding).");
    Serial.println("Output: Status LED.  Action: " + lowStr + "\t(holding).");
    Serial.println("Output: Ext St LED.  Action: " + lowStr + "\t(holding).");
    Serial.println("Output: ATX Trigger. Action: " + highStr + "\t(holding).\n");
#endif // DEBUG
    delay(10);
  }
}

/**
 * @brief softReset Instructs the Arduino to soft-reset. This method effectively wipes the contents
 * of SRAM and restarts the sketch. This DOES NOT hard-reset, so the pin states will
 * NOT change!! Peripheral reset does not occur.
 */
void softReset() {
    delay(1000);
    asm volatile ("  jmp 0");
}

/**
 * @brief doShutdownDetction Here we will perform shutdown detection of the RPi,
 * and then process button events.  Shutdown detection works like this:
 * When the RPi boots up, the TxD UART pin in the GPIO header goes high (3.3v).
 * It may go low for roughly 200ms when the hand-off to the kernel occurs, but
 * it will go high again after that and stay high until CPU_HALT, when it will
 * be driven low, despite the RPi's power indicator being on. So this routine
 * will watch for this pin to go high. When it goes low, this will make sure
 * it is really shutdown by waiting in 500ms intervals and checking again.
 * If it is still low at or after 4 seconds, then we consider the RPi to be off
 * and go ahead and switch the rest of the system off. The only way this occurs
 * is under the following conditions:
 * 1) Pin 5 (receives input from RPi TxD) is low.
 * 2) System state is not "OFF" (could be "ON" or "RESETING").
 * 3) Pin 5 has *remained* low for 4 or more seconds.
 * At that point, we switch off and update system state, then suspend the task
 * indefinitely. This task will only resume if the system is powered back on.
 * Otherwise, we just process button events and cycle back around.
 */
void doShutdownDetection() {
  // Bail if task suspended.
  if (!shutdownDetection) {
    return;
  }

  // Check shutdown detection pin (5).
  bool systemBooted = (digitalRead(SHUTDOWN_DETECT) == HIGH);
  if ((state == PMUState_OFF) && (!systemBooted)) {
    // Everything is off. Process button events.
    timeDown = 0;
    return;
  }
  else if ((state != PMUState_OFF) && (systemBooted)) {
    // Nothing to do here. System is powered on and RPi is booted up.
    // Just process button events.
    timeDown = 0;
#ifdef DEBUG
    if (!msgPrinted) {
      Serial.println(F("*** Raspberry Pi is booted up! ***\n"));
      msgPrinted = true;
    }
#endif // DEBUG
	return;
  }
  else if ((!systemBooted) && (state != PMUState_OFF) && (timeDown < shutdownThreshold)) {
    // Detection pin went low and the RPi was last known to be running.
    // At this point it is probably off... But let's wait a couple
    // seconds to be sure.
    delay(shutdownDetectDelay);
    timeDown += shutdownDetectDelay;
    return;
  }

  // RPi has been off for 4 or more seconds. Just power everything off.
  if ((!systemBooted) && (state != PMUState_OFF) && (timeDown >= shutdownThreshold)) {
#ifdef DEBUG
    Serial.println(F("*** Raspberry Pi is no longer running! Powering off!! ***\n"));
#endif // DEBUG

    // The RPi has been off for at least 2 seconds. Kill the power.
    setAllOutputExceptTriggerStates(false);

    // Wait a 10th of a second and then drop out the ATX main power.
    delay(100);
    setTriggerState(false);
    state = PMUState_OFF;
    timeDown = 0;
    suspendShutdownDetection();

#ifdef DEBUG
    String stateStr = getStateString(state);
    Serial.println("Input: Shutdown detection. Event: RPi shutdown. Action: " + stateStr);
    Serial.println("Output: Power Relay (12V). Action: " + lowStr);
    Serial.println("Output: Power Relay (5V). Action: " + lowStr);
    Serial.println("Output: Status LED.  Action: " + lowStr);
    Serial.println("Output: Ext St LED.  Action: " + lowStr);
    Serial.println("Output: ATX Trigger. Action: " + lowStr + "\n");
#endif // DEBUG
    return;
  }
}

/**
 * @brief setup Initialization routine.
 */
void setup() {
  // Wire up button events.
  ButtonEvent.addButton(short(PWR_BUTTON), onPwrDown, NULL, NULL, holdTime, NULL, interval);
  ButtonEvent.addButton(short(RST_BUTTON), onRstDown, onRstUp, onRstHold, holdTime, NULL, interval);

  // Initialize all outputs and shutdown detection pin.
  initOutputs();
  initSDdetector();

#if defined(DEBUG)
  // Open serial port and wait for connection. Then dump version and pin defs.
  Serial.begin(DEBUG_BAUD_RATE);
  while (!Serial) {
    delay(10);
  }
  reportInit();
#endif // DEBUG
}

/**
 * @brief loop The main loop.
 */
void loop() {
  // We do this in a specific order (by priority) :
  // 1) Shutdown detection (unless suspended)
  // 2) Process button events.
  doShutdownDetection();
  ButtonEvent.loop();
}

#ifdef DEBUG
/**
 * @brief getIOModeString Gets the string representation of an I/O mode.
 * @param mode The I/O mode.
 * @return The string representation of the mode.
 */
String getIOModeString(uint8_t mode) {
    String modeStr = "INPUT";
    if (mode > INPUT) {
        modeStr = "OUPUT";
    }
    return modeStr;
}

/**
 * @brief reportInit Reports system initialization info (verions, pin defs, etc).
 */
void reportInit() {
  String in = getIOModeString(INPUT);
  String out = getIOModeString(INPUT);
  delay(50);
  Serial.println("\n\n" + String(VERSION) + " initialized.\n");
  Serial.println(F("======= PIN DEFS ======="));
  Serial.print("Pin:\t");
  Serial.print(RST_BUTTON);
  Serial.print("\tAssignment:\t" + in);
  Serial.print(F("\tFunction:\tReset Button\n"));
  Serial.print("Pin:\t");
  Serial.print(PWR_BUTTON);
  Serial.print("\tAssignment:\t" + in);
  Serial.print(F("\tFunction:\tPower Button\n"));
  Serial.print("Pin:\t");
  Serial.print(SHUTDOWN_DETECT);
  Serial.print(("\tAssignment:\t" + in));
  Serial.print(F("\tFunction:\tShutdown Detection\n"));
  Serial.print(F("Pin:\t"));
  Serial.print(RST_RELAY);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tReset Relay\n"));
  Serial.print("Pin:\t");
  Serial.print(PWR_RELAY_12V);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tPower Relay (12V)\n"));
  Serial.print(F("Pin:\t"));
  Serial.print(PWR_RELAY_5V);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tPower Relay (5V)\n"));
  Serial.print(F("Pin:\t"));
  Serial.print(EXT_LED);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tExternal Status LED\n"));
  Serial.print(F("Pin:\t"));
  Serial.print(LED);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tStatus LED\n"));
  Serial.print(F("Pin:\t"));
  Serial.print(TRIGGER);
  Serial.print("\tAssignment:\t" + out);
  Serial.print(F("\tFunction:\tATX Trigger\n\n\n"));
  Serial.println(F("Waiting for input..."));
  Serial.flush();
  delay(2000);
}
#endif // DEBUG
