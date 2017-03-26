class UpLines {
  float x;
  int m, mod;

  UpLines(float xPos) {
    x = xPos;
  }

  void update(int mod, int spd, int invert, color l) {
    if (mod == 1 && m < (height * 24)) {
      m = m + spd;
    }
    else if (mod == 0 && m > 0) {
      m = m - spd;
    }
    stroke(l);
    if (m > 0) {
      line(x, height, x, height - m);
    }
  }
  void reset() {
    m = 0;
  }
}

