// lib/utils/font_loader.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class FontLoader {
  // Primary Persian font (Vazirmatn for Persian UI)
  static TextStyle vazirmatnBold({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle vazirmatnSemiBold({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.w600,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle vazirmatnRegular({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.normal,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle vazirmatnLight({double fontSize = 16, Color? color}) {
    return TextStyle(
      fontFamily: 'Vazirmatn',
      fontWeight: FontWeight.w300,
      fontSize: fontSize,
      color: color,
    );
  }

  // Secondary English font (Roboto)
  static TextStyle robotoBold({double fontSize = 16, Color? color}) {
    return GoogleFonts.roboto(
      fontWeight: FontWeight.bold,
      fontSize: fontSize,
      color: color,
    );
  }

  static TextStyle robotoRegular({double fontSize = 16, Color? color}) {
    return GoogleFonts.roboto(
      fontWeight: FontWeight.normal,
      fontSize: fontSize,
      color: color,
    );
  }

  // Theme text styles
  static TextStyle headline1({Color? color}) =>
      vazirmatnBold(fontSize: 32, color: color);

  static TextStyle headline2({Color? color}) =>
      vazirmatnBold(fontSize: 24, color: color);

  static TextStyle headline3({Color? color}) =>
      vazirmatnSemiBold(fontSize: 20, color: color);

  static TextStyle subtitle1({Color? color}) =>
      vazirmatnSemiBold(fontSize: 16, color: color);

  static TextStyle subtitle2({Color? color}) =>
      vazirmatnRegular(fontSize: 14, color: color);

  static TextStyle bodyLarge({Color? color}) =>
      vazirmatnRegular(fontSize: 16, color: color);

  static TextStyle bodyMedium({Color? color}) =>
      vazirmatnRegular(fontSize: 14, color: color);

  static TextStyle bodySmall({Color? color}) =>
      vazirmatnLight(fontSize: 12, color: color);

  static TextStyle caption({Color? color}) =>
      vazirmatnLight(fontSize: 11, color: color);

  static TextStyle button({Color? color}) =>
      vazirmatnSemiBold(fontSize: 14, color: color);

  // Get TextTheme
  static TextTheme getTextTheme() {
    return TextTheme(
      headlineLarge: headline1(),
      headlineMedium: headline2(),
      headlineSmall: headline3(),
      titleLarge: subtitle1(),
      titleMedium: subtitle2(),
      bodyLarge: bodyLarge(),
      bodyMedium: bodyMedium(),
      bodySmall: bodySmall(),
      labelSmall: caption(),
      labelMedium: button(),
    );
  }
}
