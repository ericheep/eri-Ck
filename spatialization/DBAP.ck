// Eric Heep
// January 4th, 2017
// DBAP.ck

// Distance-Based Amplitude Panning
// http://jamoma.org/publications/attachments/icmc2009-dbap-rev1.pdf

// "Distance-based amplitude panning (DBAP) extends the principle of equal
// intensity panning from a pair of speakers to a loudspeaker array of any size,
// with no a priori assumptions about their positions in space or relative to
// each other."

public class DBAP {

    float gain[0];
    float speakerCoordinates[0][2];
    float speakerDistances[0];
    float speakerWeights[0];

    int m_numChannels;
    float m_rolloff, m_spatialBlur, m_rolloffCoefficient;

    private void init() {
        3.0 => m_rolloff;
        0.001 => m_spatialBlur;
        4 => m_numChannels;
        numChannels(m_numChannels);
        computeRolloffCoefficient(m_rolloff);
    }

    init();

    public void numChannels(int n) {
        n => m_numChannels;
        gain.size(m_numChannels);
        speakerCoordinates.size(m_numChannels);
        speakerDistances.size(m_numChannels);
        speakerWeights.size(m_numChannels);
        for (0 => int i; i < m_numChannels; i++) {
            1.0 => speakerWeights[i];
        }
    }

    // "When the virtual source is located at the exact position of one of the
    // loudspeakers, only that speaker will be emitting sound. This may cause unwanted
    // changes in spatial spread and coloration of a virtual source in a similar way
    // as observed for VBAP .. the larger r, the less the source will gravitate towards one
    // speaker only."
    public void spatialBlur(float r) {
        r => m_spatialBlur;
    }

    // "..a rolloff of R = 6 dB equals the inverse distance law for sound propagating
    // in a free field. For closed or semi-closed environments R will generally be lower,
    // in the range of 3-5 dB, and depend on reflections and reverberation."
    public void rolloff(float R) {
        R => m_rolloff;
    }

    // "This enables a source to be restricted to use a subset of speakers, opening up
    // for several artistic possibilities. Installations or museum spaces speaker weights
    // can be used to confine sources to restricted areas."
    public void weights(float w[]) {
        for (0 => int i; i < m_numChannels; i++) {
            w[i] => speakerWeights[i];
        }
    }

    // set coordinates, [0.0 - 1.0]
    public void coordinates(float l[][]) {
        for (int i; i < l.size(); i++) {
            l[i] @=> speakerCoordinates[i];
        }
    }

    // dbap panning, [0.0 - 1.0]
    public float[] pan(float p[]) {
        computeSpeakerDistances(p);
        computeAmplitudeCoefficient() => float k;

        for (0 => int i; i < m_numChannels; i++) {
            (k * speakerWeights[i])/Math.pow(speakerDistances[i], m_rolloffCoefficient) => gain[i];
        }

        return gain;
    }

    private void computeRolloffCoefficient(float R) {
        R/(20.0 * Math.log10(2)) => m_rolloffCoefficient;
    }

    private float[] computeSpeakerDistances(float p[]) {
        for (0 => int i; i < m_numChannels; i++) {
            Math.sqrt(Math.pow((speakerCoordinates[i][0] - p[0]), 2) +
                      Math.pow((speakerCoordinates[i][1] - p[1]), 2) +
                      Math.pow(m_spatialBlur, 2)) => speakerDistances[i];
        }
    }

    private float computeAmplitudeCoefficient() {
        0.0 => float sum;
        for (0 => int i; i < m_numChannels; i++) {
            speakerWeights[i]/(Math.pow(speakerDistances[i], 2.0 * m_rolloffCoefficient)) +=> sum;
        }
        return 1.0/Math.sqrt(sum);
    }
}

/*
DBAP dbap;

// set channels
dbap.numChannels(4);
dbap.spatialBlur(0.0001);
dbap.rolloff(4.0);
dbap.weights([1.0, 1.2, 0.8, 0.95]);

// set speaker coordinates
dbap.coordinates([[0.0, 0.0], [0.0, 1.0], [1.0, 1.0], [1.0, 0.0]]);

float sum;
float levels[];
float coordinate[2];

for (0 => float i; i < 1.0; 0.1 +=> i) {
    Math.random2f(0.0, 1.0) => coordinate[0];
    Math.random2f(0.0, 1.0) => coordinate[1];
    dbap.pan(coordinate) @=> levels;

    float sum;
    for (0 => int i; i < levels.size(); i++) {
        Math.pow(levels[i], 2) +=> sum;
    }

    <<< "Coordinate:", coordinate[0], coordinate[1], " -  Levels:", levels[0], levels[1], levels[2], levels[3], " -  Inverse Square Sum:", sum, "" >>>;
}
*/
