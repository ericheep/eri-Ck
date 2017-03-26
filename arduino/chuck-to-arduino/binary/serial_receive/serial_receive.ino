// serial_receive.ino
// for controlling the meepo board with ChucK

# define NUM_SOLENOIDS 6

#include <avr/interrupt.h>
#include <avr/io.h>

#define LED_POWER 12
#define LED_STATUS 11
#define arduinoID 0

char bytes[2];
short notes[NUM_SOLENOIDS];

int handshake = 0;
int statustimer = 0;

// actuator pins
int actuators[] = {
  3, 5, 6, 9, 10, 11
};

void setup() {
  // serial
  Serial.begin(57600);

  // interrupt timer parameters
  TCCR2A = 1;
  TCCR2B = 3;
  TIMSK2 = 1;

  pinMode(LED_POWER, OUTPUT);
  pinMode(LED_STATUS, OUTPUT);
  digitalWrite(LED_POWER, LOW);

  for (int i = 0; i < NUM_SOLENOIDS; i++) {
    pinMode(actuators[i], OUTPUT);
    digitalWrite(actuators[i], LOW);
  }
}

// concurrency, allows solenoids to left
// high while new serial messages are read
ISR(TIMER2_OVF_vect) {
  for (int i = 0; i < NUM_SOLENOIDS; i++) {
    if (notes[i] > 0) {
      digitalWrite(actuators[i], HIGH);
      notes[i]--;
    }
    else {
      digitalWrite(actuators[i], LOW);
    }
  }
  if (statustimer > 0) {
    digitalWrite(LED_STATUS, HIGH);
    statustimer--;
  }
  else {
    digitalWrite(LED_STATUS, LOW);
  }
}

void loop() {
  if (Serial.available()) {
    // parity byte
    if (Serial.read() == 0xff) {
      // reads in a two index array from ChucK
      Serial.readBytes(bytes, 2);

      // reads the first six bits for the note number
      // then reads the last ten bits for the note velocity
      int note = byte(bytes[0]) >> 2;
      int velocity = (byte(bytes[0]) << 8 | byte(bytes[1])) & 1023;

      // message required for "handshake" to occur
      // happens once per Arduino at the start of the ChucK serial code
      // unnecessary if only using one Meepo at a time
      /*if (pitch == 63 && velocity == 1023 && handshake == 0) {
        Serial.write(arduinoID);
        handshake = 1;
      }*/

      if (note >= 0 && pitch <= NUM_SOLENOIDS) {
        statustimer = 120;
        notes[note] = (velocity * 0.5);
      }
    }
  }
}
