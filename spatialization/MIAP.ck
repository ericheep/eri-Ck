// Eric Heep
// March 7rd, 2017
// MIAP.ck

// Manifold-Interface Amplitude Panning
// Meyer Sounds's SpaceMap spatialization.

// Seldess, Zachary. 2014. "MIAP: Manifold-Interface Amplitude Panning
//      in Max/MSP and Pure Data." Presentation at the annual conference
//      of AES, Los Angeles, CA, October 9-12.

public class MIAP {

    // our node objects
    class Node {
        float coordinate[2];
        float gain;

        int index, active;
    }

    // our triset objects
    class Triset {
        int nodeId[3];

        // the node reference
        float coordinate[3][2];
        float gain[3];

        float v0[2];
        float v1[2];

        float dot00;
        float dot01;
        float dot11;

        float invDenom;

        int index, active;

        // area of the triangle
        float area;
        float areaScalar;

        // length of the sides of the triangle
        float ab, bc, ca;
    }

    Node nodes[0];
    Triset trisets[0];

    0 => int numNodes;
    0 => int numTrisets;

    public int addNode(float coordinate[]) {
        Node node;

        // set node member variables
        coordinate @=> node.coordinate;
        numNodes => node.index;

        // set index and add to array
        nodes << node;
        numNodes++;

        return node.index;
    }

    public int addTriset(int n1, int n2, int n3) {
        Triset triset;

        // set triset member variables
        nodes[n1].coordinate @=> triset.coordinate[0];
        nodes[n2].coordinate @=> triset.coordinate[1];
        nodes[n3].coordinate @=> triset.coordinate[2];

        n1 => triset.nodeId[0];
        n2 => triset.nodeId[1];
        n3 => triset.nodeId[2];

        distance(nodes[n1].coordinate, nodes[n2].coordinate) => triset.ab;
        distance(nodes[n2].coordinate, nodes[n3].coordinate) => triset.bc;
        distance(nodes[n3].coordinate, nodes[n1].coordinate) => triset.ca;

        heronArea(triset.ab, triset.bc, triset.ca) => triset.area;
        1.0/triset.area => triset.areaScalar;

        // a few pointInTriset operations that never change and
        // only should calculated when "constructing" the object
        computeVector(triset.coordinate[2], triset.coordinate[0]) @=> triset.v0;
        computeVector(triset.coordinate[1], triset.coordinate[0]) @=> triset.v1;

        dotProduct(triset.v0, triset.v0, 2) => triset.dot00;
        dotProduct(triset.v0, triset.v1, 2) => triset.dot01;
        dotProduct(triset.v1, triset.v1, 2) => triset.dot11;

        1.0/(triset.dot00 * triset.dot11 - triset.dot01 * triset.dot01) => triset.invDenom;

        // set index and add to array
        numTrisets => triset.index;
        trisets << triset;
        numTrisets++;

        return triset.index;
    }

    // main user function for panning, sets the position of the
    // object to be "panned" in xy space
    public void setPosition(float pos[]) {
        getActiveTriset() => int possiblePrevTriset;;

        // checks to see if the active triset is the current
        // triset, cuts down on processing in the common case
        // that the position is still inside a triset
        if (possiblePrevTriset >= 0) {
            if (pointInTriset(pos, trisets[possiblePrevTriset])) {
                setTrisetNodes(pos, trisets[possiblePrevTriset]);
                return;
            }
        }

        // if it is a new triset, we clear the active trisets,
        // and then scan all the trisets to find where the position
        // currently is
        clearActiveTrisets();
        clearTrisetGains();

        // if the position (derived node) does not fall in the
        // previous triset, then we scan to see if it falls
        // inside of a new triset
        for (0 => int i; i < numTrisets; i++) {
            if (pointInTriset(pos, trisets[i])) {
                1 => trisets[i].active;
                setTrisetNodes(pos, trisets[i]);
                return;
            }
        }
    }

    // utility functions
    private void clearActiveTrisets() {
        for (0 => int i; i < numTrisets; i++) {
            0 => trisets[i].active;
        }
    }

    private void clearTrisetGains() {
        for (0 => int i; i < numNodes; i++) {
            0.0 => nodes[i].gain;
        }
    }

    // finds the areas of the three triangles that make up the a triset
    // those areas sum to 1.0, and the square root of each is set to be
    // the gain for that node
    private void setTrisetNodes(float pos[], Triset triset) {
        distance(triset.coordinate[0], pos) => float ap;
        distance(triset.coordinate[1], pos) => float bp;
        distance(triset.coordinate[2], pos) => float cp;

        heronArea(triset.ab, bp, ap) => float n3Area;
        heronArea(triset.ca, ap, cp) => float n2Area;
        triset.area - n3Area - n2Area => float n1Area;

        Math.sqrt(n1Area * triset.areaScalar) => float g1;
        Math.sqrt(n2Area * triset.areaScalar) => float g2;
        Math.sqrt(n3Area * triset.areaScalar) => float g3;

        g1 => triset.gain[0] => nodes[triset.nodeId[0]].gain;
        g2 => triset.gain[1] => nodes[triset.nodeId[1]].gain;
        g3 => triset.gain[2] => nodes[triset.nodeId[2]].gain;
    }

    // area of a triangle given the lengths of its sides
    private float heronArea(float A, float B, float C) {
        (A + B + C) * 0.5 => float S;
        return Math.sqrt(S * (S - A) * (S - B) * (S - C));
    }

    // Euclidean distance between two coordinates
    private float distance(float A[], float B[]) {
        return Math.sqrt(Math.pow((B[0] - A[0]), 2) + Math.pow((B[1] - A[1]), 2));
    }

    // http://blackpawn.com/texts/pointinpoly/
    // many values were precalculated in the constructor to save on processing
    private int pointInTriset(float P[], Triset triset) {
        computeVector(P, triset.coordinate[0]) @=> float v2[];

        dotProduct(triset.v0, v2, 2) => float dot02;
        dotProduct(triset.v1, v2, 2) => float dot12;

        // compute barycentric coordinates
        (triset.dot11 * dot02 - triset.dot01 * dot12) * triset.invDenom => float u;
        (triset.dot00 * dot12 - triset.dot01 * dot02) * triset.invDenom => float v;

        // check if point is in triangle
        return (u >= 0) && (v >= 0) && ((u + v) < 1);
    }

    private float[] computeVector(float R[], float S[]) {
        return [R[0] - S[0], R[1] - S[1]];
    }

    private float dotProduct(float v[], float u[], int n) {
        0.0 => float result;

        for (0 => int i; i < n; i++) {
            v[i]*u[i] +=> result;
        }

        return result;
    }

    // helpful functions for visualizing MIAP
    public int getActiveTriset() {
        for (0 => int i; i < numTrisets; i++) {
            if (trisets[i].active == 1) {
                return trisets[i].index;
            }
        }
        return -1;
    }

    public float[][] getActiveCoordinates() {
        getActiveTriset() => int idx;;
        return [trisets[idx].coordinate[0], trisets[idx].coordinate[1], trisets[idx].coordinate[2]];
    }

    public float[] getActiveGains() {
        getActiveTriset() => int idx;
        return [trisets[idx].gain[0], trisets[idx].gain[1], trisets[idx].gain[2]];
    }

    // generates a grid that is a rows by columns set of nodes,
    // the values are normalized to 1.0, with the smaller set of nodes
    // centered around 0.0,
    public void generateGrid(int rows, int cols) {
        1.0 => float horzLen;
        Math.pow(Math.pow(horzLen, 2) - Math.pow(horzLen/2.0, 2), 0.5) @=> float vertLen;

        0.0 => float inverseMax;
        0.0 => float xCenterNudge;
        0.0 => float yCenterNudge;

        if (cols >= rows) {
            1.0/((cols- 1) * horzLen + horzLen * 0.5) => inverseMax;
            (1.0 - (((rows - 1) * vertLen) * inverseMax)) * 0.5 => yCenterNudge;
        } else {
            1.0/((rows - 1) * vertLen) => inverseMax;
            (1.0 - (((cols - 1) * horzLen + horzLen * 0.5) * inverseMax)) * 0.5 => xCenterNudge;
        }

        // add our nodes
        for (0 => int i; i < rows; i++) {
            0 => float offset;
            if (i % 2 != 0) {
                horzLen * 0.5 => offset;
            }
            for (0 => int j; j < cols; j++) {
                (j * horzLen + offset) * inverseMax + xCenterNudge => float x;
                i * vertLen * inverseMax + yCenterNudge => float y;
                addNode([x, y]);
            }
        }

        // add our trisets
        for (int i; i < rows - 1; i++) {
            for (int j; j < cols - 1; j++) {
                // trisets pointing down
                {
                    j + (cols * i) => int n1;
                    n1 + 1 => int n2;
                    j + cols * (i + 1) => int n3;

                    if (i % 2 == 1) {
                        n3++;
                    }

                    addTriset(n1, n2, n3);
                }
                // trisets pointing up
                {
                    j + (cols * i) + 1 => int n1;
                    j + cols * (i + 1) => int n2;
                    n2+ 1 => int n3;


                    if (i % 2 == 1) {
                        n1--;
                    }

                    addTriset(n1, n2, n3);
                }

            }
        }
    }
}

/*

// two channel example, not the best use case,
// but a quick way to show how the class operates
// it's still pretty slow, might need to make it
// into a Chugin later down the line

MIAP m;

// generates a grid with 4 rows and 3 columns,
// that is made up of 16 nodes
m.generateGrid(4, 4);

//        0-----1-----2-----3
//         \   / \   / \   / \
//          \ /   \ /   \ /   \
//           4-----5-----6-----7
//          / \   / \   / \   /
//         /   \ /   \ /   \ /
//        8-----9----10----11
//         \   / \   / \   / \
//          \ /   \ /   \ /   \
//           12----13----14----15

9 => int leftNode;
6 => int rightNode;

SinOsc xSin => blackhole;
SinOsc ySin => blackhole;

CNoise nois => Gain left => dac.left;
nois => Gain right => dac.right;

xSin.freq(0.51);
ySin.freq(0.72);

while (true) {
    (xSin.last() + 1.0) * 0.5 => float x;
    (ySin.last() + 1.0) * 0.5 => float y;

    m.setPosition([x, y]);

    left.gain(m.nodes[9].gain);
    right.gain(m.nodes[6].gain);

    samp => now;
}

*/
