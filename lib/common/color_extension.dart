
import 'package:flutter/material.dart';

class TColor {
  static Color get primaryColor1 => const Color.fromARGB(255, 133, 153, 253);
  static Color get primaryColor2 => Color.fromARGB(255, 98, 153, 207);

  static Color get secondaryColor1 => Color.fromARGB(255, 63, 158, 121);
  static Color get secondaryColor2 => Color.fromARGB(255, 64, 221, 161);

  static Color get heartbeatColor => const Color.fromARGB(255, 152, 44, 15);
  static Color get secundaryHeartbeatColor => const Color.fromARGB(255, 238, 112, 49);

  static List<Color> get primaryG => [ primaryColor2, primaryColor1 ];
  static List<Color> get secondaryG => [secondaryColor2, secondaryColor1];
  static List<Color> get heartbeatG => [secundaryHeartbeatColor, heartbeatColor];

  static Color get black => const Color(0xff1D1617);
  static Color get gray => const Color(0xff786F72);
  static Color get white => Color.fromARGB(255, 255, 255, 255);
  static Color get lightGray => Color.fromARGB(255, 244, 244, 244);



}