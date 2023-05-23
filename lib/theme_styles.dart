import 'package:flutter/material.dart';
import 'package:nelson_lock_manager/utilities.dart';

class ThemeStyles {
  static TextStyle getTitleStyle(BuildContext context) {
    return TextStyle(
        color: Theme.of(context).primaryColor,
        fontWeight: FontWeight.bold,
        fontSize: getTitleFontSize(context));
  }

  static const Color tableHeaderBackground = Color(0xFFebe7df);
  static const Color tableContentBorder = Color(0x000ffeee);
  static const double tableBorderWidth = 2;

  static Color? successColor = Colors.green[900];
  static Color? errorColor = Colors.red[900];
}
