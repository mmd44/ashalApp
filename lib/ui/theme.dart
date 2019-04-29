import 'package:flutter/material.dart';

class Colors {
  const Colors();

  static const Color appBarTitle = const Color(0xFFFFFFFF);
  static const Color appBarIconColor = const Color(0xFFFFFFFF);
  static const Color appBarDetailBackground = const Color(0x00FFFFFF);
  static const Color appBarGradientStart = const Color(0xFF134ba5);
  static const Color appBarGradientEnd = const Color(0xFF134ba5);

  //static const Color itemCard = const Color(0xFF434273);
  static const Color itemCard = const Color(0xFF134ba5);
  //static const Color cardListBackground = const Color(0xFF3E3963);
  static const Color cardPageBackground = const Color(0xFFFFFFFF);
  static const Color cardTitle = const Color(0xFFFFFFFF);
  static const Color cardLocation = const Color(0x66FFFFFF);
  static const Color cardDistance = const Color(0x66FFFFFF);

  static const Color primary = const Color(0xFF49505b);
}

class Dimens {
  const Dimens();

  static const cardWidth = 100.0;
  static const cardHeight = 100.0;
}

class TextStyles {
  const TextStyles();

  static const TextStyle appBarTitle = const TextStyle(
      color: Colors.appBarTitle,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 36.0);

  static const TextStyle cardTitle = const TextStyle(
      color: Colors.cardTitle,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w600,
      fontSize: 24.0);

  static const TextStyle cardSubtitle = const TextStyle(
      color: Colors.cardLocation,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w300,
      fontSize: 14.0);

  static const InputDecoration textField = const InputDecoration(
    contentPadding: EdgeInsets.all(8),
    border: InputBorder.none,
    hasFloatingPlaceholder: false,
    hintStyle: TextStyle(fontWeight: FontWeight.normal),
    helperStyle: TextStyle(color: Colors.primary, height: 0.5),
    filled: true,
  );

  static const TextStyle cardExtraInfo = const TextStyle(
      color: Colors.cardDistance,
      fontFamily: 'Poppins',
      fontWeight: FontWeight.w300,
      fontSize: 12.0);
}
