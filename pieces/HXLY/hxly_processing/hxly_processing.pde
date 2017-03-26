// hxly

import oscP5.*;
import netP5.*;

RightLines[] rightLines;
LeftLines[] leftLines;
UpLines[] upLines;
DownLines[] downLines;
NWLines[] nwLines;
NELines[] neLines;
SWLines[] swLines;
SELines[] seLines;

int scl = 1;
int amt = 20;
int speed = 35;
int invert = 1;
int reset = 0;
int colorSet, check;
float gridChance = 0.7;
float inv = 1.0/amt;

color b = color(0, 0, 0);

color l1, l2, l3;
color[] lineColor = new color[8];
int[] leftMod = new int[amt];
int[] rightMod = new int[amt];
int[] upMod = new int[amt];
int[] downMod = new int[amt];
int[] nwMod = new int[amt];
int[] neMod = new int[amt];
int[] swMod = new int[amt];
int[] seMod = new int[amt];
int[][] scaleRandom = new int[4][4];

float[][] gridRandom = new float[4][4];

/*boolean sketchFullScreen() {
  return true;
}*/

OscP5 oscP5;
NetAddress myRemoteLocation;

void setup() {
  size(displayWidth, displayHeight);
  colorMode(HSB, 360);
  smooth();
  noCursor();
  frameRate(30);
  strokeWeight(10);
  strokeCap(SQUARE);
  oscP5 = new OscP5(this, 12001);
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
  leftLines = new LeftLines[amt];
  rightLines = new RightLines[amt];
  upLines = new UpLines[amt];
  downLines = new DownLines[amt];
  nwLines = new NWLines[amt];
  neLines = new NELines[amt];
  swLines = new SWLines[amt];
  seLines = new SELines[amt];
  for (int i = 0; i < amt; i++) {
    leftLines[i] = new LeftLines(((height * inv) * i) + (height * inv * 0.5));
    rightLines[i] = new RightLines((height * inv) * i);
    upLines[i] = new UpLines((width * inv) * i);
    downLines[i] = new DownLines(((width * inv) * i) + (width * inv * 0.5));
    nwLines[i] = new NWLines((PI * 0.5 * inv * i) + (PI * 0.0) + PI/(amt * 2));
    neLines[i] = new NELines((PI * 0.5 * inv * i) + (PI * 0.0) + PI/(amt * 2));
    swLines[i] = new SWLines((PI * 0.5 * inv * i) + (PI * 1.5) + PI/(amt * 2));
    seLines[i] = new SELines((PI * 0.5 * inv * i) + (PI * 1.5) + PI/(amt * 2));
  }
  gridRandom[0][0] = 1.0;
  l1 = color(0, 0, 360);
  l2 = color(0, 360, 360);
  l3 = color(0, 0, 0);
  colorUpdate();
}

void colorUpdate() {
  for (int i = 0; i < 8; i++) {
    if (random(0, 1) > 0.3) {
      lineColor[i] = l1;
    }
    else {
      if (random(0, 1) > 0.3) {
        lineColor[i] = l2;
      }
      else {
        lineColor[i] = l3;
      }
    }
  }
}

void oscEvent(OscMessage msg) {
  if (msg.checkAddrPattern("/leftLine") == true) {
    leftMod[msg.get(0).intValue()] = (leftMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/rightLine") == true) {
    rightMod[msg.get(0).intValue()] = (rightMod[msg.get(0).intValue()] + 1) % 2;
  } 
  if (msg.checkAddrPattern("/upLine") == true) {
    upMod[msg.get(0).intValue()] = (upMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/downLine") == true) {
    downMod[msg.get(0).intValue()] = (downMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/nwLine") == true) {
    nwMod[msg.get(0).intValue()] = (nwMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/neLine") == true) {
    neMod[msg.get(0).intValue()] = (neMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/swLine") == true) { 
    swMod[msg.get(0).intValue()] = (swMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/seLine") == true) {
    seMod[msg.get(0).intValue()] = (seMod[msg.get(0).intValue()] + 1) % 2;
  }
  if (msg.checkAddrPattern("/invert") == true) {
    invert = msg.get(0).intValue();
  }
  if (msg.checkAddrPattern("/color") == true) {
    colorSet = msg.get(0).intValue();
    if (colorSet == 0) {
      b = color(0, 0, 0);
      l1 = color(0, 0, 360);
      l2 = color(0, 360, 360);
      l3 = color(0, 0, 0);
    }
    if (colorSet == 1) {
      b = color(0, 0, 360);
      l1 = color(0, 0, 0);
      l2 = color(0, 360, 360);
      l3 = color(0, 0, 360);
    }
    if (colorSet == 2) {
      b = color(0, 360, 360);
      l1 = color(0, 0, 0);
      l2 = color(0, 0, 360);
      l3 = color(0, 360, 360);
    }
    colorUpdate();
  }
  if (msg.checkAddrPattern("/scale") == true) {
    check = 0;
    scl = msg.get(0).intValue();
    while (check < 1) { 
      for (int i = 0; i < scl; i++) {
        for (int j = 0; j < scl; j++) {
          gridRandom[i][j] = (random(0, 1.0));
          scaleRandom[i][j] = int(random(2, scl));
          if (gridRandom[i][j] > gridChance) {
            check++;
          }
        }
      }
    }
  }
  if (msg.checkAddrPattern("/reset") == true) {
    for (int i = 0; i < amt; i++) {
      rightLines[i].reset();
      leftMod[i] = 0;
      leftLines[i].reset();
      rightMod[i] = 0;
      upLines[i].reset();
      upMod[i] = 0;
      downLines[i].reset();
      downMod[i] = 0;
      nwLines[i].reset();
      nwMod[i] = 0;
      neLines[i].reset();
      neMod[i] = 0;
      swLines[i].reset();
      swMod[i] = 0;
      seLines[i].reset();
      seMod[i] = 0;
    }
    check = 0;
    while (check < 1) { 
      for (int i = 0; i < scl; i++) {
        for (int j = 0; j < scl; j++) {
          gridRandom[i][j] = (random(0, 1.0));
          scaleRandom[i][j] = int(random(2, scl));
          if (gridRandom[i][j] > gridChance) {
            check++;
          }
        }
      }
    }
    colorUpdate();
  }
  if (msg.checkAddrPattern("/reverse") == true) {
    for (int i = 0; i < amt; i++) {
      leftMod[i] = 0;
      rightMod[i] = 0;
      upMod[i] = 0;
      downMod[i] = 0;
      nwMod[i] = 0;
      neMod[i] = 0;
      swMod[i] = 0;
      seMod[i] = 0;
    }
  }
}

void lines() {
  for (int i = 0; i < amt; i++) {
    leftLines[i].update(leftMod[i], speed, invert, lineColor[0]);
    rightLines[i].update(rightMod[i], speed, invert, lineColor[1]);
    upLines[i].update(upMod[i], speed, invert, lineColor[2]);
    downLines[i].update(downMod[i], speed, invert, lineColor[3]);    
    nwLines[i].update(nwMod[i], speed, invert, lineColor[4]);
    neLines[i].update(neMod[i], speed, invert, lineColor[5]);
    swLines[i].update(swMod[i], speed, invert, lineColor[6]);
    seLines[i].update(seMod[i], speed, invert, lineColor[7]);
  }
}

void grid() {
  for (int i = 0; i < scl; i++) {
    pushMatrix();
    for (int j = 0; j < scl; j++) {
      if (gridRandom[i][j] > gridChance) {
        lines();
      }
      translate(0, height);
      scale(1.0/(scaleRandom[i][j]));
    }
    popMatrix();
    translate(width, 0);
  }
}

void draw() {
  scale(1.0/scl);
  background(b);
  grid();
}