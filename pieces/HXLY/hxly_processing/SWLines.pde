class SWLines {
  float theta;
  float r, mod, x, y, cs, sn;

  SWLines(float t) {
    theta = t;
    cs = cos(theta);
    sn = sin(theta);
  }

  void update(int mod, int spd, int invert, color l) {
    if (mod == 1 && r < (height * 12)) {
      r = r + spd;
    }
    else if (mod == 0 && r > -2) {
      r = r - spd;
    }
    stroke(l);
    x = r * cs;
    y = r * sn + height;
    if (r > 0) {
      line(-1, height + 1, x, y);
    }
  }
  void reset() {
    r = 0;
  }
}

