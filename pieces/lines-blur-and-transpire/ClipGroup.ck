// ClipGroup.ck
// Class for managing specialized sample playback

public class ClipGroup extends Chubgraph {
    SndBuf clips[0];
    ADSR clipEnvs[0];
    ADSR env => outlet;
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

            clipEnvs << clipEnv;
            clips << clip;

            clips[i] => clipEnvs[i];
        }
    }

    fun void setAttack(dur a) {
        env.attackTime(a);
    }

    fun void setRelease(dur r) {
        env.releaseTime(r);
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

    fun int getNewClip(int currentClip) {
        currentClip => int newClip;
        while (newClip == currentClip) {
            Math.random2(0, clips.size() - 1) => newClip;
        }
        return newClip;
    }

    fun void rotating(dur from, dur to, dur crossFade) {
        for (0 => int i; i < clipEnvs.size(); i++) {
            clipEnvs[i].attackTime(crossFade);
            clipEnvs[i].releaseTime(crossFade);
            clipEnvs[i].keyOff();
        }

        int currentClip;
        while (true) {
            getNewClip(currentClip) => int newClip;
            clipEnvs[currentClip].keyOff();
            clipEnvs[newClip].keyOn();
            Math.random2f(from/second, to/second)::second => now;
            newClip => currentClip;
        }
    }
}

/* [ */
/*     "radio-l-1.wav", */
/*     "radio-l-2.wav", */
/*     "radio-l-3.wav", */
/*     "radio-l-4.wav", */
/*     "radio-l-5.wav" */
/* ] @=> string filenames[]; */

/* ClipGroup cg => dac; */
/* cg.setDir(me.dir() + "clips"); */
/* cg.setClips(filenames); */
/* cg.setAttack(30::second); */
/* cg.setRelease(30::second); */
/* cg.rotate(0.5::second, 0.55::second, 0.25::second); */
/* cg.play(); */

/* 30::second => now; */
/* cg.stop(); */
/* 30::second => now; */
