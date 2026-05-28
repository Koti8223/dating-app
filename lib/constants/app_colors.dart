import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFFFF4D6D);
  static const secondary = Color(0xFFFF8C69);
  static const background = Color(0xFFF8F8F8);
  static const white = Colors.white;
  static const grey = Color(0xFF9E9E9E);
  static const darkGrey = Color(0xFF424242);
  static const lightGrey = Color(0xFFEEEEEE);

  static const gradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [primary, secondary],
  );
}
