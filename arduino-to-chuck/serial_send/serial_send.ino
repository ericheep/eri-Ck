byte button[2];

void setup() {
    Serial.begin(9600);
    delay(1000);
    button[0] = 12;
    button[1] = 120;
}

void loop() {
    Serial.write(button, 2);
    delay(1000);
}
