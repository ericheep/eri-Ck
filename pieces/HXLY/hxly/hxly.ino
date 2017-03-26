#include "Tlc5940.h"
#include "colors.h"

#include <Wire.h>
#include <Adafruit_Sensor.h>
#include <Adafruit_LSM303_U.h>

// comboReader()
#define NUM_THREE_COMBOS 0
#define NUM_FOUR_COMBOS 2
int swtch[NUM_THREE_COMBOS + NUM_FOUR_COMBOS];
int comboState[NUM_THREE_COMBOS + NUM_FOUR_COMBOS];
int threeButtonCombo[NUM_THREE_COMBOS][3] = {
  
};
int fourButtonCombo[NUM_FOUR_COMBOS][4] = {
  {0, 5, 10, 15}, {3, 6, 9, 12}, 
};

// offset()
Adafruit_LSM303_Accel_Unified accel = Adafruit_LSM303_Accel_Unified(54321);
double pitch, roll;
double pitchOffset, rollOffset;
int ptch, rll, eventOne, eventTwo, eventThree, eventStateOne, eventStateTwo, eventStateThree, s1, s2, s3, s4;
float v1, v2, v3, v4;

// debounceButtons()
#define NUM_BUTTONS 16
int buttonCombo[NUM_BUTTONS];
int buttonPin[NUM_BUTTONS];
int buttonState[NUM_BUTTONS];
int lastButtonState[NUM_BUTTONS];
int reading[NUM_BUTTONS];
long lastDebounceTime[NUM_BUTTONS];
long DEBOUNCE_DELAY = 10;
long FLIGHT_TIME = 350;
long eventWait;

// multiClick() & simulPress()
int multiSwtch[NUM_BUTTONS];
int buttonMode[NUM_BUTTONS];
long past[NUM_BUTTONS];
long difference[NUM_BUTTONS];

// serialPrint()
String biteOne;
String biteTwo;
int serialSend;
int serialSwitch[NUM_BUTTONS + NUM_THREE_COMBOS + NUM_FOUR_COMBOS];
long accelWait;

// TLC5940 LED assignments
#define NUM_LEDS 16
int LEDS[NUM_LEDS][3] = {
  {0, 1, 2 }, {3, 4, 5 }, {6, 7, 8  }, {9, 10, 11  },
  {12, 13, 14  }, {15, 16, 17  }, {18, 19, 20  }, {21, 22, 23  },
  {24, 25, 26  }, {27, 28, 29  }, {30, 31, 32  }, {33, 34, 35  },
  {36, 37, 38  }, {39, 40, 41  }, {42, 43, 44  }, {45, 46, 47  },
};

//      ___           ___                         ___           ___           ___     
//     /  /\         /  /\                       /  /\         /  /\         /  /\    
//    /  /:/        /  /::\                     /  /::\       /  /::\       /  /:/_   
//   /  /:/        /  /:/\:\    ___     ___    /  /:/\:\     /  /:/\:\     /  /:/ /\  
//  /  /:/  ___   /  /:/  \:\  /__/\   /  /\  /  /:/  \:\   /  /:/~/:/    /  /:/ /::\ 
// /__/:/  /  /\ /__/:/ \__\:\ \  \:\ /  /:/ /__/:/ \__\:\ /__/:/ /:/___ /__/:/ /:/\:\
// \  \:\ /  /:/ \  \:\ /  /:/  \  \:\  /:/  \  \:\ /  /:/ \  \:\/:::::/ \  \:\/:/~/:/
//  \  \:\  /:/   \  \:\  /:/    \  \:\/:/    \  \:\  /:/   \  \::/~~~~   \  \::/ /:/ 
//   \  \:\/:/     \  \:\/:/      \  \::/      \  \:\/:/     \  \:\        \__\/ /:/  
//    \  \::/       \  \::/        \__\/        \  \::/       \  \:\         /__/:/   
//     \__\/         \__\/                       \__\/         \__\/         \__\/    

void setColor(int ledNum, LedRGB lrgb) {
  ledNum = ledNum % NUM_LEDS;
  int red_pin = LEDS[ledNum][0];
  int green_pin = LEDS[ledNum][1];
  int blue_pin = LEDS[ledNum][2];
  Tlc.set(red_pin, lrgb.r);
  Tlc.set(green_pin, lrgb.g);
  Tlc.set(blue_pin, lrgb.b);
}

void setColor(int ledNum, RGB rgb) {
  LedRGB lrgb = RGBtoLED(rgb);
  setColor(ledNum, lrgb);
}

void setColor(int ledNum, HSV hsv) {
  if (hsv.h > 359) hsv.h = hsv.h % 360;
  RGB rgb = HSVtoRGB(hsv);
  setColor(ledNum, rgb);
}

// converts RGB values from HSV conversion to TLC5940 values
LedRGB RGBtoLED(RGB rgb) {
  if(rgb.r > 1 || rgb.g > 1 || rgb.b > 1) {
    Serial.print("Exceeds expected RGB values");
  }
  else {
    LedRGB lrgb = {rgb.r*4000, rgb.g*4000, rgb.b*4000};
    return lrgb;
  }
}

// converts HSV to RGB values to be passed into LedRGB
RGB HSVtoRGB(HSV hsv) {
  // algorithm from http://en.wikipedia.org/wiki/HSL_and_HSV#Converting_to_RGB
  RGB rgb;
  RGB rgb_p;

  float chroma = hsv.v * hsv.s;
  float sector = float(hsv.h) / 60.0;
  // remainder is sector mod 2 in the real number sense
  float remainder = sector - ((int(sector) / 2) * 2) ;
  float x = chroma * (1 - abs(remainder - 1));
  switch(int(sector)) {
  case 0:
    rgb_p = (RGB){chroma, x, 0};
    break;
  case 1:
    rgb_p = (RGB){x, chroma, 0};
    break;
  case 2:
    rgb_p = (RGB){0, chroma, x};
    break;
  case 3:
    rgb_p = (RGB){0, x, chroma};
    break;
  case 4:
    rgb_p = (RGB){x, 0, chroma};
    break;
  case 5:
    rgb_p = (RGB){chroma, 0, x};
    break;
  default:
    rgb_p = (RGB){0, 0, 0};
  }

  float m = hsv.v - chroma;
  rgb = (RGB){rgb_p.r + m, rgb_p.g + m, rgb_p.b + m};
  return rgb;
}

//      ___           ___                       ___           ___   
//     /  /\         /  /\          ___        /__/\         /  /\  
//    /  /:/_       /  /:/_        /  /\       \  \:\       /  /::\ 
//   /  /:/ /\     /  /:/ /\      /  /:/        \  \:\     /  /:/\:\
//  /  /:/ /::\   /  /:/ /:/_    /  /:/     ___  \  \:\   /  /:/~/:/
// /__/:/ /:/\:\ /__/:/ /:/ /\  /  /::\    /__/\  \__\:\ /__/:/ /:/ 
// \  \:\/:/~/:/ \  \:\/:/ /:/ /__/:/\:\   \  \:\ /  /:/ \  \:\/:/  
//  \  \::/ /:/   \  \::/ /:/  \__\/  \:\   \  \:\  /:/   \  \::/   
//   \__\/ /:/     \  \:\/:/        \  \:\   \  \:\/:/     \  \:\   
//     /__/:/       \  \::/          \__\/    \  \::/       \  \:\  
//     \__\/         \__\/                     \__\/         \__\/ 

void offset() {
  sensors_event_t event; 
  accel.getEvent(&event);
  //pitch = arctan(Xa / (SQRT(Ya^2 + Za^2))
  pitchOffset = atan(event.acceleration.x/sqrt((event.acceleration.y * event.acceleration.y) + (event.acceleration.z * event.acceleration.z)));
  //roll = arctan(Ya / (SQRT(Xa^2 + Za^2))
  rollOffset = atan(event.acceleration.y/sqrt((event.acceleration.x * event.acceleration.x) + (event.acceleration.z * event.acceleration.z)));  
  if (pitchOffset < 0) {
    pitchOffset = pitchOffset * -1;
  }
  if (rollOffset < 0) {
    rollOffset = rollOffset * -1;
  }
}

void setup() {
  if(!accel.begin())
  {
    /* There was a problem detecting the ADXL345 ... check your connections */
    Serial.println("LSM303 not detected");
    while(1);
  }
  for (int i = 0; i < NUM_BUTTONS; i++) {
    buttonPin[i] = i + 22;   
    difference[i] = 1000;  
  }
  Serial.begin(9600);
  delay(1000);
  offset();
  delay(500);
  Tlc.init();
}

//      ___         ___           ___     
//     /  /\       /__/\         /__/\    
//    /  /:/_      \  \:\        \  \:\   
//   /  /:/ /\      \  \:\        \  \:\  
//  /  /:/ /:/  ___  \  \:\   _____\__\:\ 
// /__/:/ /:/  /__/\  \__\:\ /__/::::::::\
// \  \:\/:/   \  \:\ /  /:/ \  \:\~~\~~\/
//  \  \::/     \  \:\  /:/   \  \:\  ~~~ 
//   \  \:\      \  \:\/:/     \  \:\     
//    \  \:\      \  \::/       \  \:\    
//     \__\/       \__\/         \__\/   

void updateDelay(int t) {
  Tlc.update();
  delay(t);
  Tlc.clear();
}  

void comboReader() {
  // resets the combo
  for (int i = 0; i < NUM_THREE_COMBOS; i++) {
      for (int j = 0; j < 3; j++) {
        buttonCombo[threeButtonCombo[i][j]] = 0;
      }
    }
  for (int i = 0; i < NUM_FOUR_COMBOS; i++) {
      for (int j = 0; j < 4; j++) {
        buttonCombo[fourButtonCombo[i][j]] = 0;
      } 
  }
  // interprets, puts into combo states
  for (int i = 0; i < NUM_THREE_COMBOS; i++) {
    if (buttonState[threeButtonCombo[i][0]] == 1 && buttonState[threeButtonCombo[i][1]] == 1 && buttonState[threeButtonCombo[i][2]] == 1 && swtch[i] == 0) {
      swtch[i] = 1;       
      comboState[i] = (comboState[i] + 1) % 2;
    }  
    if (buttonState[threeButtonCombo[i][0]] == 0 || buttonState[threeButtonCombo[i][1]] == 0 || buttonState[threeButtonCombo[i][2]] == 0 && swtch[i] == 1) {
      swtch[i] = 0;
    }
  }
  for (int i = 0; i < NUM_FOUR_COMBOS; i++) {
     if (buttonState[fourButtonCombo[i][0]] == 1 && buttonState[fourButtonCombo[i][1]] == 1 && buttonState[fourButtonCombo[i][2]] == 1 && buttonState[fourButtonCombo[i][3]] == 1 && swtch[i + NUM_THREE_COMBOS] == 0) {
       swtch[i + NUM_THREE_COMBOS] = 1;
       comboState[i + NUM_THREE_COMBOS] = (comboState[i + NUM_THREE_COMBOS] + 1) % 2;
     }
     if (buttonState[fourButtonCombo[i][0]] == 0 || buttonState[fourButtonCombo[i][1]] == 0 || buttonState[fourButtonCombo[i][2]] == 0 || buttonState[fourButtonCombo[i][3]] == 0 && swtch[i + NUM_THREE_COMBOS] == 1) {
       swtch[i + NUM_THREE_COMBOS] = 0;  
     }
  }
  // puts data into buttonCombo()
  for (int i = 0; i < NUM_THREE_COMBOS; i++) {
    if (comboState[i] == 1) {
      for (int j = 0; j < 3; j++) {
        buttonCombo[threeButtonCombo[i][j]] = buttonCombo[threeButtonCombo[i][j]]++;
      }
    }
  }
  for (int i = 0; i < NUM_FOUR_COMBOS; i++) {
    if (comboState[i + NUM_THREE_COMBOS] == 1) {  
      for (int j = 0; j < 4; j++) {
        buttonCombo[fourButtonCombo[i][j]] = buttonCombo[fourButtonCombo[i][j]]++;
      }
    }
  }
  if (buttonState[5] == 1 && buttonState[6] == 1 && buttonState[8] == 1 && buttonState[11] == 1 && buttonState[13] == 1 && buttonState[14] == 1) {
    for (int i = 0; i < NUM_THREE_COMBOS + NUM_FOUR_COMBOS; i++) {
      comboState[i] = 0;  
    }
  }
  // eventOne
  if (buttonState[4] == 1 && buttonState[5] == 1 && buttonState[6] == 1 && buttonState[7] == 1 && buttonState[8] == 1 && buttonState[9] == 1 && buttonState[10] == 1 && buttonState[11] == 1 && eventStateOne == 0) {  
    eventOne++;
    eventOne = eventOne % 3;
    eventStateOne = 1;
    Serial.println(eventOne + 8000);
  }
  if (buttonState[4] == 0 || buttonState[5] == 0 || buttonState[6] == 0 || buttonState[7] == 0 || buttonState[8] == 0 || buttonState[9] == 0 || buttonState[10] == 0 || buttonState[11] == 0 && eventStateOne == 1) {  
    eventStateOne = 0;
  } 
  // eventTwo
  if (buttonState[1] == 1 && buttonState[2] == 1 && buttonState[5] == 1 && buttonState[6] == 1 && buttonState[9] == 1 && buttonState[10] == 1 && buttonState[13] == 1 && buttonState[14] == 1 && eventStateTwo == 0) {  
    eventTwo++;
    eventTwo = eventTwo % 4;
    eventStateTwo = 1;
    eventWait = 500;
    Serial.println(eventTwo + 9000);
  }
  if (eventWait > 0) {
    eventWait = eventWait - 1;
  }
  if (buttonState[1] == 0 || buttonState[2] == 0 || buttonState[5] == 0 || buttonState[6] == 0 || buttonState[9] == 0 || buttonState[10] == 0 || buttonState[13] == 0 || buttonState[14] == 0 && eventStateTwo == 1) {  
    eventStateTwo = 0;
  }
  if (buttonState[0] == 1 && buttonState[3] == 1 && eventStateThree == 0) {
    eventThree = 1;
    eventStateThree = 1;
    Serial.println(eventThree + 7000);
  }
  if (buttonState[0] == 0 || buttonState[3] == 0 && eventStateThree == 1) {
    eventThree = 0;
    Serial.println(eventThree + 7000);
    eventStateThree = 0;
  }
}

void debounceButtons() {
  for (int i = 0; i < NUM_BUTTONS; i++) {
    reading[i] = digitalRead(buttonPin[i]);
    if (reading[i] != lastButtonState[i]) {
      lastDebounceTime[i] = millis();
    }
    if ((millis() - lastDebounceTime[i]) > DEBOUNCE_DELAY) {
      if (reading[i] != buttonState[i]) {
        buttonState[i] = reading[i];
      }
    }
    lastButtonState[i] = reading[i];  
  }
}

void multiClick() {  
  for (int i; i < NUM_BUTTONS; i++) {
    if (buttonState[i] == 1 && multiSwtch[i] == 0) {
      multiSwtch[i] = 1;
      if (difference[i] < FLIGHT_TIME && millis() - past[i] < FLIGHT_TIME) {
        buttonMode[i] = buttonMode[i]++;
      }
      else buttonMode[i] = 0;
      past[i] = millis();
    }
    if (buttonState[i] == 0 && multiSwtch[i] == 1) {
       multiSwtch[i] = 0;
       difference[i] = millis() - past[i];
    }
  } 
}

void buttonLights() {
  if (eventOne == 0) {
    v1 = 0.0; 
    v2 = 1.0;
    s3 = 0.0;
    v3 = 0.2;
  }
  if (eventOne == 1) {
    s1 = 0;
    v1 = 0.5; 
    v2 = 0.0;
    s3 = 1.0;
    v3 = 1.0;
  }
  if (eventOne == 2) {
    s1 = 1;
    v2 = 0.5;
    s3 = 0.0;
    v3 = 0.0;
  }  
  for (int i = 0; i < NUM_BUTTONS; i++) {
    buttonState[i] = buttonState[i] * (buttonMode[i] + 1);
    HSV hsv = {0, s1, v1};
    setColor(i, hsv);
  }
  if (eventWait > 0 && eventOne == 0) {
    for (int i = 0; i < 4; i++) {
      HSV hsv = {0, 0, 1 * (eventWait * 0.002)};
      setColor(i + (eventTwo * 4), hsv);
    }
  }
  if (eventWait > 0 && eventOne == 1) {
    for (int i = 0; i < 4; i++) {
      HSV hsv = {0, 1 * (eventWait * 0.002), 0.5};
      setColor(i + (eventTwo * 4), hsv);
    }
  }
  if (eventWait > 0 && eventOne == 2) {
    for (int i = 0; i < 4; i++) {
      HSV hsv = {0, 1 * ((eventWait * -1 + 500) * 0.002), 0.5};
      setColor(i + (eventTwo * 4), hsv);
    }
  }
  for (int i = 0; i < NUM_BUTTONS; i++) {
    if (buttonCombo[i] > 0) {
      HSV hsv = {0, s3, v3};
      setColor(i, hsv);
    }
    if (buttonState[i] > 0) {
      HSV hsv = {0, 0, v2};
      setColor(i, hsv);
    }
  }
}

void serialPrint() {
  for (int i = 0; i < NUM_BUTTONS; i++) {
    if (buttonState[i] > 0 && serialSwitch[i] == 0) {
      serialSwitch[i] = 1;
      serialSend = buttonState[i] + ((i + 1) * 100);
      Serial.println(serialSend); 
    }
    if (buttonState[i] == 0 && serialSwitch[i] == 1) {
       serialSwitch[i] = 0;
       serialSend = buttonState[i] + ((i + 1) * 100);
       Serial.println(serialSend);
    }
  }
  for (int i = 0; i < NUM_THREE_COMBOS + NUM_FOUR_COMBOS; i++) {
    if (comboState[i] > 0 && serialSwitch[i  + NUM_BUTTONS] == 0) {
      serialSwitch[i + NUM_BUTTONS] = 1;
      serialSend = comboState[i] + ((i + NUM_BUTTONS + 1) * 100);
      Serial.println(serialSend); 
    }
    if (comboState[i] == 0 && serialSwitch[i + NUM_BUTTONS] == 1) {
      serialSwitch[i + NUM_BUTTONS] = 0;
      serialSend = comboState[i] + ((i + NUM_BUTTONS + 1) * 100);
      Serial.println(serialSend);
    }    
  }
  if (millis() > accelWait ) {
    accelWait = millis() + 50;
    accellRead();
    Serial.println(ptch);
    Serial.println(rll);
  }
}

void accellRead() {
    sensors_event_t event; 
    accel.getEvent(&event);
    //pitch = arctan(Xa / (SQRT(Ya^2 + Za^2))
    pitch = atan(event.acceleration.x/sqrt((event.acceleration.y * event.acceleration.y) + (event.acceleration.z * event.acceleration.z))) + pitchOffset;
    //roll = arctan(Ya / (SQRT(Xa^2 + Za^2))
    roll = atan(event.acceleration.y/sqrt((event.acceleration.x * event.acceleration.x) + (event.acceleration.z * event.acceleration.z))) + rollOffset;
    ptch = (int) ((pitch * 100) + 150);
    rll = (int) ((roll * 100) + 150);
    ptch = constrain(ptch, 0, 300) + 4000;
    rll = constrain(rll, 0, 300) + 5000;  
}  

//                        ___           ___           ___   
//                       /  /\         /  /\         /  /\  
//                      /  /::\       /  /::\       /  /::\ 
//   ___       ___     /  /:/\:\     /  /:/\:\     /  /:/\:\
//  /__/\     /  /\   /  /:/  \:\   /  /:/  \:\   /  /:/~/:/
//  \  \:\   /  /:/  /__/:/ \__\:\ /__/:/ \__\:\ /__/:/ /:/ 
//   \  \:\ /  /:/   \  \:\ /  /:/ \  \:\ /  /:/ \  \:\/:/  
//    \  \:\  /:/     \  \:\  /:/   \  \:\  /:/   \  \::/   
//     \  \:\/:/       \  \:\/:/     \  \:\/:/     \  \:\   
//      \  \::/         \  \::/       \  \::/       \  \:\  
//       \__\/           \__\/         \__\/         \__\/ 

int ctr;
int inc;

void loop() {
  inc++;
  debounceButtons();
  comboReader();
  multiClick();
  buttonLights();
  serialPrint();
  updateDelay(0);
}
