// Eric Heep
// February 15th, 2017
// binaryCellularAutomataMidiOut.ck
//
/* rule 110 (01101110 in binary)

           -0-                 -1-                -2-                -3-
    |---| |---| |---|   |---| |---| |---|  |---| |---| |---|  |---| |---| |---|
    | 0 | | 0 | | 0 |   | 0 | | 0 | | 1 |  | 0 | | 1 | | 0 |  | 0 | | 1 | | 1 |
    |---| |---| |---|   |---| |---| |---|  |---| |---| |---|  |---| |---| |---|

          |---|               |---|              |---|              |---|
          | 0 |               | 1 |              | 1 |              | 1 |
          |---|               |---|              |---|              |---|


           -4-                 -5-                -6-                -7-
    |---| |---| |---|   |---| |---| |---|  |---| |---| |---|  |---| |---| |---|
    | 1 | | 0 | | 0 |   | 1 | | 0 | | 1 |  | 1 | | 1 | | 0 |  | 1 | | 1 | | 1 |
    |---| |---| |---|   |---| |---| |---|  |---| |---| |---|  |---| |---| |---|

          |---|               |---|              |---|              |---|
          | 0 |               | 1 |              | 1 |              | 0 |
          |---|               |---|              |---|              |---|
*/

class BinaryCellularAutomata {

    // init
    110 => int rule;
    8 => int bitLength;
    1 => int wrap;

    fun void setRule(int r) {
        r => rule;
    }

    fun void setBitLength(int b) {
        b => bitLength;
    }

    fun void setWrap(int w) {
        w => wrap;
    }

    fun int getLookup(int input, int idx) {
        /* Returns which part of the rule, or the lookup, should
        be from it's neighbors. The lookup will always be a number
        from 0 to 7.

        Parameters
        ----------
            input : int
                The integer that represents the current binary
                cellular automata pattern.
            idx : int
                The bit location of the cell we're updating.
        Returns
        -------
        lookup : int
            Which part of the rule the three bits coorespond to.
        */

        if (idx == 0) {
            if (wrap) {
                return (input >> bitLength - 1) | ((input & 3) << 1);
            }
            else {
                return (input & 3) << 1;
            }
        }
        else if (idx == (bitLength - 1)) {
            if (wrap) {
                return ((input >> idx) & 3) | ((input & 1) << 2);
            }
            else {
                return (input >> idx) & 3;
            }
        }
        else {
            return (input >> (idx - 1)) & 7;
	}
    }

    fun int generate(int input) {
        /* Returns the next integer generated by the BCA

        Parameters
        ----------
            input : int
                The integer that represents the current binary
                cellular automata pattern.

        Returns
        -------
            output : int
                The integer that represents the next binary
                cellular automata pattern.
        */

        int output, lookup, state;
        for (0 => int i; i < bitLength; i++) {
            getLookup(input, i) => lookup;

            (rule >> lookup) & 1 => state;
            (state << i) | output => output;
        }
        return output;
    }
}

fun string binaryString(int num, int bitLength) {
    /* Returns an integer as a string in it's binary form.
    Useful for checking output.

    Parameters
    ----------
    num : int
        number
    bitLength : int
        number of bits to represent

    Returns
    -------
    output : string
        string representation of the number in binary

    */
    string output;
    for (int i; i < bitLength; i++) {
        ((num >> i) & 1) + " " + output => output;
    }
    return output;
}

/*
// A standard cellular automata (CA) generator that utilizes
// binary operations to create patterns of cells.
//
// This application of CA produces patterns which are interpreted
// as midiOut messages that are synced to the Ableton tempo. This script
// is also initially uses 30, and can be read about from the following link.
//
// http://mathworld.wolfram.com/CellularAutomaton.html
//
// Rule 30 and 110 are the two most utilized patterns,
// but feel free to experiment with others.
//
// Due to the way this CA is calculated, the maximum bitLength is 64.

BinaryCellularAutomata bca;
SqrOsc sqr => dac;

16 => int bitLength;

// bca parameters
bca.setBitLength(bitLength);
bca.setRule(30);
bca.setWrap(true);

// puts a 1 at the middle(ish) the of first input
1 << (bitLength/2) => int input;

while (true) {
    for (0 => int i; i < bitLength; i++) {
        ((input >> i) & 1 == 1) => int state;

        // if the bit is high, play midi note
        if (state) {
            sqr.gain(1.0);
            sqr.freq(440 * (i + 1));
        }

        100::ms => now;
        sqr.gain(0.0);
    }

    // view the cellular automata patterns
    <<< binaryString(input, bitLength), "" >>>;

    // generate the next pattern of cells
    bca.generate(input) => input;
}
*/
