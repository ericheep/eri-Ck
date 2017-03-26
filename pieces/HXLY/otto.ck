public class MrOtto {
    
    // constants (kept in order)
    16 => int NUM_BUTTONS;
    2 => int NUM_COMBOS;
    2 => int NUM_ACCELLS;
    3 => int NUM_EVENTS;
    
    // digital arrays
    int digitalData[NUM_BUTTONS + NUM_COMBOS];
    int button[NUM_BUTTONS]; 
    int combo[NUM_COMBOS];
    int event[NUM_EVENTS];
    
    // analog arrays
    int analogData[NUM_ACCELLS];
    int accell[NUM_ACCELLS];
    
    // serial 
    SerialIO serial;
    
    fun void initSerial() {
        SerialIO.list() @=> string list[];
        for( int i; i < list.cap(); i++ ) {
            chout <= i <= ": " <= list[i] <= IO.newline();
        }
        serial.open(2, SerialIO.B9600, SerialIO.ASCII);
        3.5::second => now;
        spork ~ serialPoller();
    }
    
    // one at a time serial poller
    fun void serialPoller() {
        while (true) {
            serial.onLine() => now;
            serial.getLine() => string bridge;
            if (Std.atoi(bridge) > 7999 && Std.atoi(bridge) < 9000 && bridge.length() > 3) {
                Std.atoi(bridge.substring(bridge.length() - 2)) => event[0];
            }
            if (Std.atoi(bridge) > 8999 && bridge.length() > 3) {
                Std.atoi(bridge.substring(bridge.length() - 2)) => event[1];
            }
            if (Std.atoi(bridge) > 6999 && Std.atoi(bridge) < 8000 && bridge.length() > 3) {
                Std.atoi(bridge.substring(bridge.length() - 2)) => event[2];
            }
            if (Std.atoi(bridge) > 4000 && Std.atoi(bridge) < 7000 && bridge.length() > 3) {
                Std.atoi(bridge.substring(1)) => analogData[(bridge.charAt(0) - 48) - 4];
            }
            if (Std.atoi(bridge) < 4000 && bridge.length() > 3) {
                Std.atoi(bridge.substring(bridge.length() - 2)) => digitalData[Std.atoi(bridge.substring(0, bridge.length() - 3)) - 1];
            }
            // translation
            for (int i; i < NUM_ACCELLS; i++) {
                analogData[i] => accell[i];
            }
            for (int i; i < NUM_BUTTONS; i++) {
                digitalData[i] => button[i];
            }
            for (int i; i < NUM_COMBOS; i++) {
                digitalData[i + NUM_BUTTONS] => combo[i];
            }
        }
    }
    
    // prints all digital and analog data
    fun void print() {
        string printData;
        for (int i; i < digitalData.cap(); i++) {
            printData + (digitalData[i] + " ") => printData;
        }
        for (int i ; i < event.cap(); i++) {
            printData + (event[i] + " ") => printData;
        }
        for (int i; i < analogData.cap(); i++) {
            printData + (analogData[i] + " ") => printData;
        }
        <<< printData, "" >>>;    
    }
}





