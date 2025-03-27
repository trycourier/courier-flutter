import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {

  static const Color primaryColor = Color(0xFF9747FF);
  static const Color lightColor = Colors.white;
  static const Color secondaryColor = Colors.black45;

  static final TextStyle sectionText = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 20,
    color: primaryColor
  );

  static final TextStyle titleText = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.normal,
    fontSize: 18,
  );

  static final TextStyle unreadTitleText = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 18,
  );

  static final TextStyle bodyText = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  static final TextStyle unreadBodyText = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

  static final ButtonStyle buttonStyle = FilledButton.styleFrom(
    backgroundColor: Colors.grey.shade300,
    foregroundColor: Colors.black,
    textStyle: bodyText
  );

  static final ButtonStyle unreadButtonStyle = FilledButton.styleFrom(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      textStyle: bodyText
  );

  static final TextStyle body = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.normal,
    fontSize: 16,
  );

  static final TextStyle title = GoogleFonts.sen().copyWith(
    fontWeight: FontWeight.bold,
    fontSize: 16,
  );

}