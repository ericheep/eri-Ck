class NWLines {
  float theta;
  float r, mod, x, y, cs, sn;

  NWLines(float t) {
    theta = t;
    cs = cos(theta);
    sn = sin(theta);
  }

  void update(int mod, int spd, int invert, color l) {
    if (mod == 1 && r < (height * 12)) {
      r = r + spd;
    }
    else if (mod == 0 && r > 0) {
      r = r - spd;
    }
    stroke(l);
    x = r * cs;
    y = r * sn;
    if (r > 0) {
      line(-1, -1, x, y);
    }
  }
  void reset() {
    r = 0;
  }
}

