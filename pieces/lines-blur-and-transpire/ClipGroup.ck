// ClipGroup.ck
// Class for managing specialized sample playback
// add in pauses from this time to this time

public class ClipGroup extends Chubgraph {
    SndBuf clips[0];
    ADSR clipEnvs[0];
    PowerADSR env => outlet;
    env.attackCurve(5.0);
    env.releaseCurve(5.0);
    "" => string dir;

    int fadingIn;
    dur fadeOut;

    fun void setDir(string d) {
        d + "/" => dir;
    }

    fun void setClips(string clipNames[]) {
        for (0 => int i; i < clipNames.size(); i++) {
            SndBuf clip;
            clip.read(dir + clipNames[i]);
            clip.pos(clip.samples());
            clip.loop(1);

            ADSR clipEnv;
            clipEnv.keyOn();
            //clipEnv.attackCurve(5.0);
            //clipEnv.releaseCurve(5.0);

            clipEnvs << clipEnv;
            clips << clip;

            clips[i] => clipEnvs[i];
        }
    }

    fun void setGain(float g) {
        for (0 => int i; i < clips.size(); i++) {
            clips[i].gain(g);
        }
    }

    fun void setAttackRelease(dur a, dur r) {
        env.set(a, 0.0::samp, 1.0, r);
        r => fadeOut;
    }

    fun void play() {
        env.keyOn();
        true => fadingIn;
        for (0 => int i; i < clips.size(); i++) {
            clipEnvs[i] => env;
            clips[i].pos(0);
        }
    }

    fun void stopAfter(dur fadeOut) {
        fadeOut => now;
        if (!fadingIn) {
            for (0 => int i; i < clips.size(); i++) {
                clips[i].pos(clips[i].samples());
                clipEnvs[i] =< env;
            }
        }
    }

    fun void stop() {
        env.keyOff();
        false => fadingIn;
        spork ~ stopAfter(fadeOut);
    }

    fun void rotate(dur from, dur to, dur crossFade) {
        spork ~ rotating(from, to, crossFade);
    }

    fun void pauses(dur from, dur to, dur fade, dur silence) {
        spork ~ pausing(from, to, fade, silence);
    }

    fun int getNewClip(int currentClip) {
        currentClip => int newClip;
        while (newClip == currentClip) {
            Math.random2(0, clips.size() - 1) => newClip;
        }
        return newClip;
    }

    fun void rotating(dur from, dur to, dur crossFade) {
        for (0 => int i; i < clipEnvs.size(); i++) {
            clipEnvs[i].set(crossFade, 0.0::second, 1.0, crossFade);
        }

        int currentClip;
        while (true) {
            getNewClip(currentClip) => int newClip;
            clipEnvs[newClip].keyOn();
            Math.random2f(from/second, to/second)::second => dur seconds;
            seconds - (crossFade/2) => now;
            clipEnvs[newClip].keyOff();
            crossFade/2 => now;
            newClip => currentClip;
        }
    }

    fun void pausing(dur from, dur to, dur fade, dur silence) {
        for (0 => int i; i < clipEnvs.size(); i++) {
            clipEnvs[i].set(fade, 0.0::second, 1.0, fade);
        }

        while (true) {
            for (0 => int i; i < clipEnvs.size(); i++) {
                clipEnvs[i].keyOn();
            }
            fade => now;
            Math.random2f(from/second, to/second)::second => dur seconds;
            seconds => now;
            for (0 => int i; i < clipEnvs.size(); i++) {
                clipEnvs[i].keyOff();
            }
            fade + silence => now;
        }
    }
}

/* [ */
/*     "metal-74hz.wav", */
/*     "metal-515hz.wav" */
/* ] @=> string filenames[]; */

/* ClipGroup cg => dac; */
/* cg.setDir(me.dir() + "clips"); */
/* cg.setClips(filenames); */
/* cg.setAttackRelease(30::second, 30::second); */
/* cg.pauses(6.0::second, 12.0::second, 5.0::second, 5.0::second); */
/* cg.setGain(0.7); */
/* // cg.rotate(5.0::second, 6.0::second, 4.0::second); */
/* cg.play(); */

/* hour => now; */

/* cg.stop(); */
/* 30::second => now; */
