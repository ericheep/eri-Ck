// Eric Heep
// March 13th, 2017
// MIDIValue.ck

public class MIDIValue {
    // incoming value
    0 => int m_midiVal;

    // outgoing values
    0.0 => float m_scaledVal;
    0.0 => float m_expVal;

    // eased value vars
    0.0 => float m_easedVal;
    0.0 => float m_easingIncrement;
    0.0 => float m_augment;

    // utility float
    1.0/127.0 => float midiScale;

    fun void setMidiVal(int midiVal) {
        midiVal => m_midiVal;
    }

    fun float getScaledVal() {
        return m_midiVal * midiScale;
    }

    fun float getExponentialVal(int pow) {
        return Math.pow(getScaledVal(), pow);
    }

    fun void setEasingIncrement(float inc) {
        inc => m_easingIncrement;
    }

    fun float getEasedScaledVal() {
        if (m_easedVal < getScaledVal() - m_easingIncrement) {
            m_easingIncrement => m_augment;
            m_easedVal + m_easingIncrement => m_easedVal;
        }
        else if (m_easedVal > getScaledVal() + m_easingIncrement) {
            -m_easingIncrement => m_augment;
            m_easedVal - m_easingIncrement => m_easedVal;
        }
        return m_easedVal;
    }

    fun float getExponentialEasedVal(int pow) {
        return Math.pow(getEasedScaledVal(), pow);
    }

}
