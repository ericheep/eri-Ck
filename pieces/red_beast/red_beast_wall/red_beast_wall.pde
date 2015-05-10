// Eric Heep
// 7444447, wall of the beast

import oscP5.*;
import netP5.*;

import codeanticode.syphon.*;
PGraphics canvas;
SyphonServer server;

int cols = 7;
int[] rows = { 
  7, 4, 4, 4, 4, 4, 7
};
float[] initial_pos = {  
  0.0, 0.175, 0.305, 0.435, 0.565, 0.695, 0.825
};
float[] initial_width = { 
  0.175, 0.13, 0.13, 0.13, 0.13, 0.13, 0.175
};

Box[][] box;
float [][] box_width;
float [][] box_height;

String [] box_width_addr = {
  "/ww0", "/ww1", "/ww2", "/ww3", "/ww4", "/ww5", "/ww6"
};
String [] box_height_addr = {
  "/wh0", "/wh1", "/wh2", "/wh3", "/wh4", "/wh5", "/wh6"
};

OscP5 oscP5;
NetAddress myRemoteLocation;

/*boolean sketchFullScreen() {
  return true;
}*/

void setup() {
  size(1280, 1024, P3D);
  noCursor();
  frameRate(30);

  canvas = createGraphics(width, height, P3D);
  server = new SyphonServer(this, "Processing Syphon");

  // array instantiations
  box = new Box[cols][];
  box_width = new float[cols][];
  box_height = new float[cols][];

  for (int i = 0; i < cols; i++) {
    box[i] = new Box[rows[i]];
    box_width[i] = new float[rows[i]];
    box_height[i] = new float[rows[i]];
  }

  // constructor
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows[i]; j++) {
      box[i][j] = new Box(j, rows[i], initial_pos[i], initial_width[i]);
    }
  }
  oscP5 = new OscP5(this, 12002); // use port for listening
  myRemoteLocation = new NetAddress("127.0.0.1", 12000);
}

// osc event listener
void oscEvent(OscMessage msg) {
  for (int i = 0; i < cols; i++) {
    if (msg.checkAddrPattern(box_width_addr[i])) {
      for (int j = 0; j < rows[i]; j++) {
        box_width[i][j] = msg.get(j).floatValue();
      }
    }
    if (msg.checkAddrPattern(box_height_addr[i])) {
      for (int j = 0; j < rows[i]; j++) {
        box_height[i][j] = msg.get(j).floatValue();
      }
    }
  }
}

// main loop, sending to Syphon
void draw() {
  canvas.beginDraw();
  canvas.background(0);
  canvas.colorMode(HSB, 360);
  canvas.rectMode(CORNERS);
  canvas.strokeWeight(4);

  // updating all our boxes
  for (int i = 0; i < cols; i++) {
    for (int j = 0; j < rows[i]; j++) {
      box[i][j].update(box_width[i][j], box_height[i][j], i);
    }
  }

  canvas.endDraw();
  //image(canvas, 0, 0);
  server.sendImage(canvas);
}
