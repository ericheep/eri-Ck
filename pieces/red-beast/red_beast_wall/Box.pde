class Box {

  // locations
  float x1, y1, x2, y2;

  // other vars
  float w, h, sw, sh;

  // amount, position, width percentage
  Box (int idx, int num, float pos, float wid) {
    // width and height of box
    w = wid * width;
    h = height/float(num);

    // coordinates
    x1 = pos * width;
    x2 = x1 + (wid * width);    
    y1 = idx * h;
    y2 = (idx + 1) * h;
  }

  void update(float x_val, float y_val, int col) {
    // multi sins
    if (x_val <= 1.0 && y_val <= 1.0) {
      canvas.fill(0, 360, 360);
      sw = (1.0 - x_val) * w * 0.5;
      sh = (1.0 - y_val) * h * 0.5;
      canvas.rect(x1 + sw, y1 + sh, x2 - sw, y2 - sh);
    }
    // circle sin
    if (x_val >= 1.0 && x_val <= 2.0) {
      canvas.fill(0, 360, 360);
      canvas.rect(x1, y1, x2, y2 - (2.0 - y_val) * h);
    }
    // big sin
    // lows
    if (x_val >= 2.0 && x_val <= 3.0) {
      x_val -= 2.0;
      if (col == 3) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
      if (col == 0) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
      if (col == 1) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
      if (col == 2) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
      if (col == 4) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        if (x_val == 1.0) {
          canvas.fill(0, 360, 360);
        } else {
          canvas.rect(x1 + sw, y1, x2, y2);
        }
      }
      if (col == 5) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
      if (col == 6) {
        sw = x_val * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1 + sw, y1, x2, y2);
      }
    }
    // high
    if (x_val > 3.0 && x_val <= 4.0) {
      x_val -= 3.0;
      if (col == 3) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
      if (col == 1) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
      if (col == 2) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
      if (col == 4) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
      if (col == 5) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
      if (col == 6) {
        sw = (1.0 - x_val) * w;
        canvas.fill(0, 360, 360);
        canvas.rect(x1, y1, x2 - sw, y2);
      }
    }
  }
}

