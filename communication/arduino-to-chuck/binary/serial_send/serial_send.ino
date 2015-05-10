// Eric Heep
// May 2015

// basic serial protocol for sending an 
// array of bytes from Arduino into ChucK

// the first value is our sentinel byte, 0xff == 255
byte bytes[] = {0xff, 1, 2};

void setup() {
    Serial.begin(9600);
}

// sends out our array
void loop() {
    Serial.write(bytes, 3);
    delay(500);
}
