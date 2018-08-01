MidiIn nK2;

5 => int nK2Port;

<<< "About to open nK2:", nK2Port >>>;

if (!nK2.open(nK2Port))
{
    <<< "Can't open nK2 port", nK2Port >>>;
    me.exit();
}

<<< "Looks OK -- nK2:", nK2Port >>>;
