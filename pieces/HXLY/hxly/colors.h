struct HSV {
  int h;
  float s;
  float v;
};

struct LedRGB {
  int r;
  int g;
  int b;
};

struct RGB {
  float r;
  float g;
  float b;
};

LedRGB RGBtoLED(RGB rgb);
RGB HSVtoRGB(HSV hsv);

void setColor(int ledNum, HSV hsv);
void setColor(int ledNum, RGB rgb);
void setColor(int ledNum, LedRGB lrgb);


// list of color names - lefted from POVRAY
#define AQUAMARINE              0.439216,   0.858824,   0.576471
#define BAKERS_CHOC             0.36,       0.20,       0.09
#define BLACK                   0.0,        0.0,        0.0
#define BLUE                    0.0,        0.0,        1.0
#define BLUE_VIOLET             0.62352,    0.372549,   0.623529
#define BRASS                   0.71,       0.65,       0.26
#define BRIGHT_GOLD             0.85,       0.85,       0.10
#define BRONZE                  0.55,       0.47,       0.14
#define BRONZE2                 0.65,       0.49,       0.24
#define BROWN                   0.647059,   0.164706,   0.164706
#define CADET_BLUE              0.372549,   0.623529,   0.623529
#define COOL_COPPER             0.85,       0.53,       0.10
#define COPPER                  0.72,       0.45,       0.20
#define CORAL                   1.0,        0.498039,   0.0
#define CORN_FLOWER_BLUE        0.258824,   0.258824,   0.435294
#define CYAN                    0.0,        1.0,        1.0
#define DARK_BROWN              0.36,       0.25,       0.20
#define DARK_GREEN              0.184314,   0.309804,   0.184314
#define DARK_GREEN_COPPER       0.29,       0.46,       0.43
#define DARK_OLIVE_GREEN        0.309804,   0.309804,   0.184314
#define DARK_ORCHID             0.6,        0.196078,   0.8
#define DARK_PURPLE             0.53,       0.12,       0.47
#define DARK_SLATE_BLUE         0.419608,   0.137255,   0.556863
#define DARK_SLATE_GRAY         0.184314,   0.309804,   0.309804
#define DARK_TAN                0.59,       0.41,       0.31
#define DARK_TURQUOISE          0.439216,   0.576471,   0.858824
#define DARK_WOOD               0.52,       0.37,       0.26
#define DIM_GRAY                0.329412,   0.329412,   0.329412
#define DUSTY_ROSE              0.52,       0.39,       0.39
#define FELDSPAR                0.82,       0.57,       0.46
#define FIRE_BRICK              0.556863,   0.137255,   0.137255
#define FLESH                   0.96,       0.80,       0.69
#define FOREST_GREEN            0.137255,   0.556863,   0.137255
#define GOLD                    0.8,        0.498039,   0.196078
#define GOLDENROD               0.858824,   0.858824,   0.439216
#define GRAY                    0.752941,   0.752941,   0.752941
#define GREEN                   0.0,        1.0,        0.0
#define GREEN_COPPER            0.32,       0.49,       0.46
#define GREEN_YELLOW            0.576471,   0.858824,   0.439216
#define HUNTERS_GREEN           0.13,       0.37,       0.31
#define INDIAN_RED              0.309804,   0.184314,   0.184314
#define KHAKI                   0.623529,   0.623529,   0.372549
#define LIGHT_BLUE              0.74902,    0.847059,   0.847059
#define LIGHT_GRAY              0.658824,   0.658824,   0.658824
#define LIGHT_PURPLE            0.87,       0.58,       0.98
#define LIGHT_STEEL_BLUE        0.560784,   0.560784,   0.737255
#define LIGHT_WOOD              0.91,       0.76,       0.65
#define LIME_GREEN              0.196078,   0.8,        0.196078
#define MAGENTA                 1.0,        0.0,        1.0
#define MANDARIN_ORANGE         0.89,       0.47,       0.20
#define MAROON                  0.556863,   0.137255,   0.419608
#define MEDIUM_AQUAMARINE       0.196078,   0.8,        0.6
#define MEDIUM_BLUE             0.196078,   0.196078,   0.8
#define MEDIUM_FOREST_GREEN     0.419608,   0.556863,   0.137255
#define MEDIUM_GOLDENROD        0.917647,   0.917647,   0.678431
#define MEDIUM_ORCHID           0.576471,   0.439216,   0.858824
#define MEDIUM_PURPLE           0.73,       0.16,       0.96
#define MEDIUM_SEA_GREEN        0.258824,   0.435294,   0.258824
#define MEDIUM_SLATE_BLUE       0.498039,   0.0,        1.0
#define MEDIUM_SPRING_GREEN     0.498039,   1.0,        0.0
#define MEDIUM_TORQUOISE        0.439216,   0.858824,   0.858824
#define MEDIUM_VIOLET_RED       0.858824,   0.439216,   0.576471
#define MEDIUM_WOOD             0.65,       0.50,       0.39
#define MIDNIGHT_BLUE           0.184314,   0.184314,   0.309804
#define NAVY                    0.137255,   0.137255,   0.556863
#define MAVY_BLUE               0.137255,   0.137255,   0.556863
#define NEON_BLUE               0.30,       0.30,       1.00
#define NEON_PINK               1.00,       0.43,       0.78
#define NEW_MIDNIGHT_BLUE       0.00,       0.00,       0.61
#define NEW_TAN                 0.92,       0.78,       0.62
#define OLD_GOLD                0.81,       0.71,       0.23
#define ORANGE                  1.0,        0.5,        0.0
#define ORANGE_RED              1.0,        0.25,       0.0
#define ORCHID                  0.858824,   0.439216,   0.858824
#define PALE_GREEN              0.560784,   0.737255,   0.560784
#define PINK                    0.737255,   0.560784,   0.560784
#define PLUM                    0.917647,   0.678431,   0.917647
#define QUARTZ                  0.85,       0.85,       0.95
#define RED                     1.0,        0.0,        0.0
#define RICH_BLUE               0.35,       0.35,       0.67
#define SALMON                  0.435294,   0.258824,   0.258824
#define SCARLET                 0.55,       0.09,       0.09
#define SEA_GREEN               0.137255,   0.556863,   0.419608
#define SEMI_SWEET_CHOC         0.42,       0.26,       0.15
#define SIENNA                  0.556863,   0.419608,   0.137255
#define SILVER                  0.90,       0.91,       0.98
#define SKY_BLUE                0.196078,   0.6,        0.8
#define SLATE_BLUE              0.498039,   1.0,        0.0
#define SPICY_PINK              1.00,       0.11,       0.68
#define SPRING_GREEN            1.0,        0.498039,   0.0
#define STEEL_BLUE              0.137255,   0.419608,   0.556863
#define SUMMER_SKY              0.22,       0.69,       0.87
#define TAN                     0.858824,   0.576471,   0.439216
#define THISTLE                 0.847059,   0.74902,    0.847059
#define TURQUOISE               0.678431,   0.917647,   0.917647
#define VERY_DARK_BROWN         0.35,       0.16,       0.14
#define VERY_LIGHT_GRAY         0.80,       0.80,       0.80
#define VERY_LIGHT_PURPLE       0.94,       0.81,       0.99
#define VIOLET                  0.309804,   0.184314,   0.309804
#define VIOLET_RED              0.8,        0.196078,   0.6
#define WHEAT                   0.847059,   0.847059,   0.74902
#define WHITE                   1.0,        1.0,        1.0
#define YELLOW                  1.0,        1.0,        0.0
