#include "Tlc5940.h"
#include "colors.h"

// ID number of the arduino, cooresponds
// to an individual Puck
#define arduinoID 0

// LED stuff
#define NUM_LEDS 16
#define NUM_TLCS 3

// stores our incoming values
char bytes[2];
int handshake;

int LEDS[NUM_LEDS][3];
float hues[NUM_LEDS];
float sats[NUM_LEDS];
float vals[NUM_LEDS];

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
  if (rgb.r > 1 || rgb.g > 1 || rgb.b > 1) {
    Serial.print("Exceeds expected RGB values");
  }
  else {
    LedRGB lrgb = {
      rgb.r * 4000, rgb.g * 4000, rgb.b * 4000
    };
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
  switch (int(sector)) {
    case 0:
      rgb_p = (RGB) {
        chroma, x, 0
      };
      break;
    case 1:
      rgb_p = (RGB) {
        x, chroma, 0
      };
      break;
    case 2:
      rgb_p = (RGB) {
        0, chroma, x
      };
      break;
    case 3:
      rgb_p = (RGB) {
        0, x, chroma
      };
      break;
    case 4:
      rgb_p = (RGB) {
        x, 0, chroma
      };
      break;
    case 5:
      rgb_p = (RGB) {
        chroma, 0, x
      };
      break;
    default:
      rgb_p = (RGB) {
        0, 0, 0
      };
  }

  float m = hsv.v - chroma;
  rgb = (RGB) {
    rgb_p.r + m, rgb_p.g + m, rgb_p.b + m
  };
  return rgb;
}

void setup() {
  // start serial port at 9600 bps and wait for port to open
  // might change to a higher baudrate later on
  Serial.begin(57600);

  for (int i = 0; i < NUM_LEDS; i++) {
    for (int j = 0; j < 3; j++) {
      LEDS[i][j] = i * 3 + j;
    }
    hues[i] = 0.0;
    sats[i] = 0.0;
    vals[i] = 0.0;
  }
  Tlc.init();
}

void loop() {
  if (Serial.available()) {
    if (Serial.read() == 0xff) {
      // reads in a two index array from ChucK
      Serial.readBytes(bytes, 4);

      // bit wise operations
      // ~~~~~~~~~~~~~~~~~~~
      // reads the first six bits for the note number
      // then reads the last ten bits for the note velocity
      int led = byte(bytes[0]) >> 2;
      int hue = (byte(bytes[0]) << 8 | byte(bytes[1])) & 1023;
      int sat = byte(bytes[2]);
      int val = byte(bytes[3]);

      // message required for "handshake" to occur
      // happens once per Arduino at the start of the ChucK serial code
      if (led == 63 && hue == 1023 && handshake == 0) {
        Serial.write(arduinoID);
        handshake = 1;
      }
      else {
        HSV hsv = {
          hue/1024.0 * 360.0, sat/255.0, pow(val/255.0, 7)
        };
        setColor(led, hsv);
        Tlc.update();
      }
    }
  }
}
