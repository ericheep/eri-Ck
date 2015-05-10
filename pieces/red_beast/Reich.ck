public class Reich extends Chubgraph {

    LiSa mic;
    inlet => mic => outlet;
    int recOn;
    int playOn;
    int bounce;
    int random;
    dur recTime;
    4 => int numVoices;
    float voice_speed, last_speed;
    8::second => dur buffer;

    fun void duration(dur length) {
        mic.duration(length); 
    }

    fun void record(int rcrd) {
        if (rcrd == 1) {
            spork ~ recording();
        }
        if (rcrd == 0) {
            0 => recOn; 
        }
    }

    fun void recording() {
        1 => recOn;
        mic.duration(buffer);
        mic.playPos(0::samp);
        mic.record(1);
        now => time x;
        while (recOn == 1) {
            1::samp => now;
        }
        now => time y;
        y - x => recTime;
        mic.record(0);
    }

    fun void play(int ply) {
        if (ply == 1) {
            1 => playOn;
            spork ~ playing();
        }
        if (ply == 0) {
            0 => playOn;
        }

    }

    fun void playing() {
        for (int i; i < numVoices; i++) {
            mic.play(i, 1);
            if (random) {
                mic.playPos(i, recTime * Math.random2f(0.0, 1.0));
            }
            mic.loop(i, 1);
            mic.bi(i, bounce);
            mic.loop(i, 1);
            mic.loopEnd(i, recTime);
        }
        while (playOn == 1) {
            10::ms => now;
            if (voice_speed != last_speed) {
                voice_speed => last_speed;
                for (int i; i < numVoices; i++) {
                    mic.rate(i, voice_speed + i * 0.01);
                    if (random) {
                        mic.playPos(i, recTime * Math.random2f(0.0, 1.0));
                    }
                }
            }
        }
        for (int i; i < numVoices; i++) {
            mic.play(i, 0);
        }
    }

    fun void bi(int b) {
        b => bounce;
    }

    fun void voices(int num) {
        num => numVoices; 
    }

    fun void randomPos(int r) {
        r => random;
    }

    fun void speed(float spd) {
        spd => voice_speed;
    }
}
