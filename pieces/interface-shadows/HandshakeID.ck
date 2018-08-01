// HandshakeID.ck
// Eric Heep
// creates a static instantiation of the Handshake class
// allows child classes to send serial through it

public class HandshakeID {
    static Handshake @ talk;
}

new Handshake @=> HandshakeID.talk;
