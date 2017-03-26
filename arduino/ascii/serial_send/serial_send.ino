// Eric Heep
// May 2015

// basic serial protocol for sending an 
// array of ints from Arduino into ChucK

// the main differenc between this protocol
// and the binary one, is this one allows messages
// greater than 255 to be sent

// the first value is our sentinel message, 0xff == 255
int data[] = {
  0xff, 1, 2};

void setup() {
  Serial.begin(9600);
}

// sends out our array
void loop() {
  for (int i = 0; i < 3; i++) {
    Serial.println(data[i]);
  }
  delay(500);
}



