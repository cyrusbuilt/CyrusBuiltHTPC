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

#include <ButtonEvent.h>
#include <PMUState.h>

#define VERSION "Raspi_ATX_PMU V1.8b"

// Comment the following line to disable debug mode.
#define DEBUG 1

#ifdef DEBUG
#define DEBUG_BAUD_RATE 9600
// High and low (on/off) state strings.
String highStr = getStateString(int(HIGH));
String lowStr = getStateString(int(LOW));
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

// Local vars.
const int holdTime = 3000;             // How long to wait to consider the reset button held down.
const int interval = 200;              // The interval to check button state.
const int shutdownThreshold = 4000;    // The amount of time to wait to consider the RPi shut down.
const int shutdownDetectDelay = 500;   // The amount of time to delay shutdown detection.
int state = PMUStateClass::OFF;        // The current system state.
int stateOld = state;                  // The old system state (used for comparison).
int timeDown = 0;                      // The amount of time the RPi appears to have been down.

// Forward declaration of DuinOS tasks.
declareTaskLoop(shutdownDetection);
declareTaskLoop(buttonEventLoop);

// Power button down event handler.
void onPwrDown(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  if (state == PMUStateClass::RESETING) {
    return;
  }

  // Get button value and compare current state to old state.
  // Are we changing states?
  if (state == PMUStateClass::ON) {
    state = PMUStateClass::OFF;
  }
  else {
    state = PMUStateClass::ON;
  }

  // Compare to previous state.
  if (state != stateOld) {
    // If state changed to 'ON', then turn power on; Otherwise, turn it off.
    if (state == PMUStateClass::ON) {
      // Turn the ATX supply on first, then wait a little bit.
      digitalWrite(TRIGGER, HIGH);
      delay(50);

      // We should have the power to kick on the relays and LEDs now.
      digitalWrite(PWR_RELAY_12V, HIGH);
      digitalWrite(PWR_RELAY_5V, HIGH);
      digitalWrite(LED, HIGH);
      digitalWrite(EXT_LED, HIGH);
      
      // We have power now, so resume the shutdown detection task.
      resumeTask(shutdownDetection);
    }
    else {
      // Kill the relays and LEDs.
      digitalWrite(PWR_RELAY_12V, LOW);
      digitalWrite(PWR_RELAY_5V, LOW);
      digitalWrite(LED, LOW);
      digitalWrite(EXT_LED, LOW);

      // Wait a little bit and then drop out the ATX power.
      delay(50);
      digitalWrite(TRIGGER, LOW);
    }

    stateOld = state;

#ifdef DEBUG
    String stateStr = getStateString(state);
    Serial.println("Input: Power Button. Event: Pressed. Action: " + stateStr);
    Serial.println("Output: Power Relay. Action: " + stateStr);
    Serial.println("Output: Status LED.  Action: " + stateStr);
    Serial.println("Output: Ext St LED.  Action: " + stateStr);
    Serial.println("Output: ATX Trigger. Action: " + stateStr + "\n");
#endif // DEBUG
  }
}

// Power button up event handler.
void onPwrUp(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
#ifdef DEBUG
    // We don't actually do anthing with this for now. Just report it.
    Serial.println("Input: Power Button. Event: Released. Action: None.\n");
#endif // DEBUG
  }
}

// Power button hold event handler.
void onPwrHold(ButtonInformation* sender) {
  if (int(sender->analogValue) == HIGH) {
#ifdef DEBUG
    // We don't actually do anthing with this for now. Just report it.
    Serial.println("Input: Power Button. Event: Hold. Action: None.\n");
#endif // DEBUG
  }
}

// Power button double event handler.
void onPwrDouble(ButtonInformation* sender) {
  if (int(sender->analogValue) == HIGH) {
#ifdef DEBUG
    // We don't actually do anthing with this for now. Just report it.
    Serial.println("Input: Power Button. Event: Double-press. Action: None.\n");
#endif // DEBUG
  }
}

// Reset button down event handler.
void onRstDown(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  if (state == PMUStateClass::ON) {
    digitalWrite(RST_RELAY, HIGH);
    digitalWrite(LED, LOW);
    digitalWrite(EXT_LED, LOW);
    state = PMUStateClass::RESETING;
#ifdef DEBUG
    String stateStr = getStateString(state);
    Serial.println("Input: Reset Button. Event: Pressed. Action: " + stateStr);
    Serial.println("Output: Reset Relay. Action: " + highStr);
    Serial.println("Output: Status LED.  Action: " + lowStr);
    Serial.println("Output: Ext St LED.  Action: " + lowStr);
    Serial.println("Output: ATX Trigger. Action: " + highStr + "\n");
#endif // DEBUG
  }
}

// Reset button up event hanlder.
void onRstUp(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  if (state == PMUStateClass::RESETING) {
    digitalWrite(RST_RELAY, LOW);
    digitalWrite(LED, HIGH);
    digitalWrite(EXT_LED, HIGH);
    state = PMUStateClass::ON;
#ifdef DEBUG
    String stateStr = getStateString(state);
    Serial.println("Input: Reset Button. Event: Released. Action: " + stateStr);
    Serial.println("Output: Reset Relay. Action: " + lowStr);
    Serial.println("Output: Status LED.  Action: " + highStr);
    Serial.println("Output: Ext St LED.  Action: " + highStr);
    Serial.println("Output: ATX Trigger. Action: " + highStr + "\n");
#endif // DEBUG
  }
}

// Reset button hold event handler.
void onRstHold(ButtonInformation* sender) {
  if (int(sender->analogValue) == LOW) {
    return;
  }

  // Just delay on hold. We don't want to finish the reset cycle until the
  // operator releases the button.
  if (state == PMUStateClass::RESETING) {
#ifdef DEBUG
    Serial.println("Input: Reset Button. Event: Hold. Action: None.");
    Serial.println("Output: Reset Relay. Action: " + highStr + "\t(holding).");
    Serial.println("Output: Status LED.  Action: " + lowStr + "\t(holding).");
    Serial.println("Output: Ext St LED.  Action: " + lowStr + "\t(holding).");
    Serial.println("Output: ATX Trigger. Action: " + highStr + "\t(holding).\n");
#endif // DEBUG
    delay(10);
  }
}

// Reset button double-press event handler.
void onRstDouble(ButtonInformation* sender) {
  if (int(sender->analogValue) == HIGH) {
#ifdef DEBUG
    // We don't actually do anthing with this for now. Just report it.
    Serial.println("Input: Reset Button. Event: Double-press. Action: None.\n");
#endif // DEBUG
  }
}

// Here we will perform shutdown detection of the RPi, and then process button
// events.  Shutdown detection works like this:
// When the RPi boots up, the TxD UART pin in the GPIO header goes high (3.3v).
// It may go low for roughly 200ms when the hand-off to the kernel occurs, but
// it will go high again after that and stay high until CPU_HALT, when it will
// be driven low, despite the RPi's power indicator being on. So this routine
// will watch for this pin to go high. When it goes low, this will make sure
// it is really shutdown by waiting in 500ms intervals and checking again.
// If it is still low at or after 4 seconds, then we consider the RPi to be off
// and go ahead and switch the rest of the system off. The only way this occurs
// is under the following conditions:
// 1) Pin 5 (receives input from RPi TxD) is low.
// 2) System state is not "OFF" (could be "ON" or "RESETING").
// 3) Pin 5 has *remained* low for 4 or more seconds.
// At that point, we switch off and update system state, then suspend the task
// indefinitely. This task will only resume if the system is powered back on.
// Otherwise, we just process button events and cycle back around.
taskLoop(shutdownDetection) {
  // Check shutdown detection pin (5).
  bool systemBooted = (digitalRead(SHUTDOWN_DETECT) == HIGH);
  if ((state == PMUStateClass::OFF) && (!systemBooted)) {
    // Everything is off. Process button events.
    timeDown = 0;
  }
  else if ((state != PMUStateClass::OFF) && (systemBooted)) {
    // Nothing to do here. System is powered on and RPi is booted up.
    // Just process button events.
    timeDown = 0;
#ifdef DEBUG
    if (!msgPrinted) {
      Serial.println("*** Raspberry Pi is booted up! ***\n");
      msgPrinted = true;
    }
#endif // DEBUG
  }
  else if ((!systemBooted) && (state != PMUStateClass::OFF) && (timeDown < shutdownThreshold)) {
    // Detection pin went low and the RPi was last known to be running.
    // At this point it is probably off... But let's wait a couple
    // seconds to be sure.
    delay(shutdownDetectDelay);
    timeDown += shutdownDetectDelay;
    ButtonEvent.loop();
    return;
  }

  // RPi has been off for 4 or more seconds. Just power everything off.
  if ((!systemBooted) && (state != PMUStateClass::OFF) && (timeDown >= shutdownThreshold)) {
#ifdef DEBUG
    Serial.println("*** Raspberry Pi is no longer running! Powering off!! ***\n");
#endif // DEBUG

    // The RPi has been off for at least 2 seconds. Kill the power.
    digitalWrite(PWR_RELAY_12V, LOW);
    digitalWrite(PWR_RELAY_5V, LOW);
    digitalWrite(LED, LOW);
    digitalWrite(EXT_LED, LOW);

    // Wait a 10th of a second and then drop out the ATX main power.
    delay(100);
    digitalWrite(TRIGGER, LOW);
    state = PMUStateClass::OFF;
    timeDown = 0;
    suspend();

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

// Process button events.
taskLoop(buttonEventLoop) {
  ButtonEvent.loop();
}

// Initialization routine.
void setup() {
  // Wire up button events.
  ButtonEvent.addButton(short(PWR_BUTTON), onPwrDown, onPwrUp, onPwrHold, holdTime, onPwrDouble, interval);
  ButtonEvent.addButton(short(RST_BUTTON), onRstDown, onRstUp, onRstHold, holdTime, onRstDouble, interval);

  // Set output pins.
  pinMode(RST_RELAY, OUTPUT);
  pinMode(PWR_RELAY_12V, OUTPUT);
  pinMode(PWR_RELAY_5V, OUTPUT);
  pinMode(LED, OUTPUT);
  pinMode(EXT_LED, OUTPUT);
  pinMode(TRIGGER, OUTPUT);

  // Set pin 5 as input and then enable internal pull-up resistor by driving it high.
  pinMode(SHUTDOWN_DETECT, INPUT);
  digitalWrite(SHUTDOWN_DETECT, HIGH);

#ifdef DEBUG
  // Open serial port and wait for connection. Then dump version and pin defs.
  Serial.begin(DEBUG_BAUD_RATE);
  while (!Serial) {
    delay(10); 
  }
  reportInit();
#endif // DEBUG

  // Create the DuinOS tasks.
  createTaskLoop(shutdownDetection, LOW_PRIORITY);
  createTaskLoop(buttonEventLoop, NORMAL_PRIORITY);
}

// The main loop.
void loop() {
  // All we do here is delay 10ms and then execute the next task.
  delay(10);
  nextTask();
}

#ifdef DEBUG
// Gets the string representation of an I/O mode.
String getIOModeString(uint8_t mode) {
  String modeStr = "INPUT";
  if (mode > INPUT) {
    modeStr = "OUPUT";
  }
  return modeStr;
}

// Gets the string representation of an output state.
String getStateString(int state) {
  String stateStr = "OFF";
  if (state == PMUStateClass::ON) {
    stateStr = "ON";
  }
  else if (state == PMUStateClass::RESETING) {
    stateStr = "RESETING";
  }
  return stateStr;
}

// Reports system initialization info (verions, pin defs, etc).
void reportInit() {
  delay(50);
  Serial.println("\n\n" + String(VERSION) + " initialized.\n");
  Serial.println("======= PIN DEFS =======");
  Serial.print("Pin:\t");
  Serial.print(RST_BUTTON);
  Serial.print(("\tAssignment:\t" + getIOModeString(INPUT)));
  Serial.print("\tFunction:\tReset Button\n");
  Serial.print("Pin:\t");
  Serial.print(PWR_BUTTON);
  Serial.print(("\tAssignment:\t" + getIOModeString(INPUT)));
  Serial.print("\tFunction:\tPower Button\n");
  Serial.print("Pin:\t");
  Serial.print(SHUTDOWN_DETECT);
  Serial.print(("\tAssignment:\t" + getIOModeString(INPUT)));
  Serial.print("\tFunction:\tShutdown Detection\n");
  Serial.print("Pin:\t");
  Serial.print(RST_RELAY);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tReset Relay\n");
  Serial.print("Pin:\t");
  Serial.print(PWR_RELAY_12V);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tPower Relay (12V)\n");
  Serial.print("Pin:\t");
  Serial.print(PWR_RELAY_5V);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tPower Relay (5V)\n");
  Serial.print("Pin:\t");
  Serial.print(EXT_LED);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tExternal Status LED\n");
  Serial.print("Pin:\t");
  Serial.print(LED);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tStatus LED\n");
  Serial.print("Pin:\t");
  Serial.print(TRIGGER);
  Serial.print(("\tAssignment:\t" + getIOModeString(OUTPUT)));
  Serial.print("\tFunction:\tATX Trigger\n\n\n");
  Serial.println("Waiting for input...");
  Serial.flush();
  delay(2000);
}
#endif // DEBUG

