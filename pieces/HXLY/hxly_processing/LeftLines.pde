class LeftLines {
  float y;
  int m, mod;

  LeftLines(float yPos) {
    y = yPos;
  }

  void update(int mod, int spd, int invert, color l) {
    if (mod == 1 && m < (width * 24)) {
      m = m + spd;
    }
    else if (mod == 0 && m > -2) {
      m = m - spd;
    }
    stroke(l);
    if (m > 0) {
      line(-2, y, m, y);
    }
  }
  void reset() {
    m = 0;
  }
}

