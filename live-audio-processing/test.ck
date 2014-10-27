Quneo q;

Hid hi;
HidMsg msg;
0 => int device;
if (!hi.openKeyboard(device)) me.exit();
<<< hi.name() + " is fully operational.", "">>>;

[0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30] @=> int padLEDGreen[];

int ctrA, ctrB, ctrC;


while (true) {
    for (int j; j < padLEDGreen.cap(); j++) {
        q.led(144, padLEDGreen[j], 100);
        100::samp => now;
        if (q.pad[0] > 1) {
            <<< "!" >>>;
        }
    }
}

while (true) {
    hi => now;
    while (hi.recv(msg)) {
        if (msg.isButtonDown()) {
            if (msg.ascii == 96) {
                ctrA++;           
            }
            if (msg.ascii == 49) {
                ctrA--;
            }
            if (msg.ascii == 50) {
                ctrB++;           
            }
            if (msg.ascii == 51) {
                ctrB--;
            }
            if (msg.ascii == 52) {
                ctrC++;           
            }
            if (msg.ascii == 53) {
                ctrC--;
            }
            q.led(ctrA, ctrB, ctrC);
            <<< ctrA, ctrB, ctrC >>>;
        }
    }
    if (msg.isButtonUp()) {

    }
}
