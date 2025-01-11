// Keys and buttons
// Most of the keys/buttons are modeled after USB HUT 1.12
// (see http://www.usb.org/developers/hidpage).
// Abbreviations in the comments:
// AC - Application Control
// AL - Application Launch Button
// SC - System Control
pub const ungrab = 0;
pub const grab = 1;

pub const kbdDevicePath = "/dev/input/by-id";

pub const KEY_RESERVED = 0;
pub const KEY_ESC = 1;
pub const KEY_1 = 2;
pub const KEY_2 = 3;
pub const KEY_3 = 4;
pub const KEY_4 = 5;
pub const KEY_5 = 6;
pub const KEY_6 = 7;
pub const KEY_7 = 8;
pub const KEY_8 = 9;
pub const KEY_9 = 10;
pub const KEY_0 = 11;
pub const KEY_MINUS = 12;
pub const KEY_EQUAL = 13;
pub const KEY_BACKSPACE = 14;
pub const KEY_TAB = 15;
pub const KEY_Q = 16;
pub const KEY_W = 17;
pub const KEY_E = 18;
pub const KEY_R = 19;
pub const KEY_T = 20;
pub const KEY_Y = 21;
pub const KEY_U = 22;
pub const KEY_I = 23;
pub const KEY_O = 24;
pub const KEY_P = 25;
pub const KEY_LEFTBRACE = 26;
pub const KEY_RIGHTBRACE = 27;
pub const KEY_ENTER = 28;
pub const KEY_LEFTCTRL = 29;
pub const KEY_A = 30;
pub const KEY_S = 31;
pub const KEY_D = 32;
pub const KEY_F = 33;
pub const KEY_G = 34;
pub const KEY_H = 35;
pub const KEY_J = 36;
pub const KEY_K = 37;
pub const KEY_L = 38;
pub const KEY_SEMICOLON = 39;
pub const KEY_APOSTROPHE = 40;
pub const KEY_GRAVE = 41;
pub const KEY_LEFTSHIFT = 42;
pub const KEY_BACKSLASH = 43;
pub const KEY_Z = 44;
pub const KEY_X = 45;
pub const KEY_C = 46;
pub const KEY_V = 47;
pub const KEY_B = 48;
pub const KEY_N = 49;
pub const KEY_M = 50;
pub const KEY_COMMA = 51;
pub const KEY_DOT = 52;
pub const KEY_SLASH = 53;
pub const KEY_RIGHTSHIFT = 54;
pub const KEY_KPASTERISK = 55;
pub const KEY_LEFTALT = 56;
pub const KEY_SPACE = 57;
pub const KEY_CAPSLOCK = 58;
pub const KEY_F1 = 59;
pub const KEY_F2 = 60;
pub const KEY_F3 = 61;
pub const KEY_F4 = 62;
pub const KEY_F5 = 63;
pub const KEY_F6 = 64;
pub const KEY_F7 = 65;
pub const KEY_F8 = 66;
pub const KEY_F9 = 67;
pub const KEY_F10 = 68;
pub const KEY_NUMLOCK = 69;
pub const KEY_SCROLLLOCK = 70;
pub const KEY_KP7 = 71;
pub const KEY_KP8 = 72;
pub const KEY_KP9 = 73;
pub const KEY_KPMINUS = 74;
pub const KEY_KP4 = 75;
pub const KEY_KP5 = 76;
pub const KEY_KP6 = 77;
pub const KEY_KPPLUS = 78;
pub const KEY_KP1 = 79;
pub const KEY_KP2 = 80;
pub const KEY_KP3 = 81;
pub const KEY_KP0 = 82;
pub const KEY_KPDOT = 83;

pub const KEY_ZENKAKUHANKAKU = 85;
pub const KEY_102ND = 86;
pub const KEY_F11 = 87;
pub const KEY_F12 = 88;
pub const KEY_RO = 89;
pub const KEY_KATAKANA = 90;
pub const KEY_HIRAGANA = 91;
pub const KEY_HENKAN = 92;
pub const KEY_KATAKANAHIRAGANA = 93;
pub const KEY_MUHENKAN = 94;
pub const KEY_KPJPCOMMA = 95;
pub const KEY_KPENTER = 96;
pub const KEY_RIGHTCTRL = 97;
pub const KEY_KPSLASH = 98;
pub const KEY_SYSRQ = 99;
pub const KEY_RIGHTALT = 100;
pub const KEY_LINEFEED = 101;
pub const KEY_HOME = 102;
pub const KEY_UP = 103;
pub const KEY_PAGEUP = 104;
pub const KEY_LEFT = 105;
pub const KEY_RIGHT = 106;
pub const KEY_END = 107;
pub const KEY_DOWN = 108;
pub const KEY_PAGEDOWN = 109;
pub const KEY_INSERT = 110;
pub const KEY_DELETE = 111;
pub const KEY_MACRO = 112;
pub const KEY_MUTE = 113;
pub const KEY_VOLUMEDOWN = 114;
pub const KEY_VOLUMEUP = 115;
pub const KEY_POWER = 116; // SC System Power Down
pub const KEY_KPEQUAL = 117;
pub const KEY_KPPLUSMINUS = 118;
pub const KEY_PAUSE = 119;
pub const KEY_SCALE = 120; // AL Compiz Scale (Expose)