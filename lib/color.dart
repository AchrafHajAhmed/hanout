import 'package:flutter/material.dart';

class AppColors {
  static const Color primaryColor = Color(0xFFF7E034);
  static const Color secondaryColor = Color (0xFFEF3F3F);
  static const Color thirdColor = Color (0xFF000000);
  static const Color TextColor = Color (0xFF757373);
  static const Color ButtonColor = Color (0xFF757373);



  static LinearGradient get background => LinearGradient(
    colors: [primaryColor, secondaryColor],
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
  );
}
