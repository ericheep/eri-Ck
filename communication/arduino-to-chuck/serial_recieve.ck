// Eric Heep
// basic serial protocol for receiving an 
// array of bytes into ChucK from Arduino

SerialIO serial;
SerialIO.list() @=> string list[];

for(int i; i < list.cap(); i++) {
    <<< i, ":", list[i], "" >>>;
}

fun int device() {
    // assigns a 'usb' port as a serial port
    // granted you only have one USB device connected
    int port;
    for (int i; i < list.cap(); i++) {
        if (list[i].find("usb") > 0) {
            i => port;
        }
    }
    <<< "-", "" >>>;
    <<< "Connecting to", list[port], "on port", port, "" >>>;
    return port;
}

serial.open(device(), SerialIO.B9600, SerialIO.BINARY);
int data[2];

while (true) {
    serial.onBytes(2) => now; 
    serial.getBytes() @=> data;
    if (data != NULL) {
        <<< "Incoming Bytes:", data[0], data[1], "" >>>;
    }
}
