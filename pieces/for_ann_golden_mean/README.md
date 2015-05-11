# for-ann-golden-mean

A recreation of James Tenney's "For Ann (rising)."
This recreation uses the the golden mean instead of a JI minor sixth, the result is that each first order difference tone reinforces the sine wave below it. The intent was to create what Marc Sabat describes in the paragraph below.

“I have heard Tenney consider a possible modification of this piece which would, I think, be an interesting exploration. He suggests that each glissando be related to the one on either side by the ratio which is the limit of the ratios of successive Fibonacci terms (2:1, 3:2, 5:3, 8:5, 13:8, 21:13...), or about 1.618033988749894 (etc.), a minor sixth. This interval (quite a nice one - about 833 cents, as compared to 813.7 for the 8/5, 840.5 for the 13/8, and 800 for the tempered) which the current version of the piece only approximates, would result in the property of all first order difference tones of any given glissando pair being already present in some lower glissando. That is, all resultant tones would simply replicate existing ones, and the piece might conceivably be smoother, or more “perfect”. This rather simple yet surprising result of the Fibonacci numbers, or more accurately of the “golden mean”, can be seen visually in the common representations of it as a sequence of inscribed rectangles with sides proportioned in this fashion.”

Analysis of the piece was done in Python using music information retrieval techniques to closely approximate the parameters that James Tenney used.

Requires ChucK 1.3.5.1 (gidora) which includes the WinFuncEnv chugin.

Eric Heep,
May 2015
