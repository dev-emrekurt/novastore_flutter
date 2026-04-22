import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

const ColorScheme colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFFDBAF1C),
  onPrimary: Colors.white,
  secondary: Color(0xFFC9E4DB),
  onSecondary: Colors.black,
  error: Color(0xFFB00020),
  onError: Colors.white,
  surface: Color(0xFF7C9E95),
  onSurface: Color(0xFF013042),
);

// İsterseniz doğrudan temayı da burada oluşturabilirsiniz
final ThemeData myTheme = ThemeData(
  useMaterial3: true,
  colorScheme: colorScheme,
  textTheme: GoogleFonts.montserratTextTheme(ThemeData.light().textTheme),
  // Ekstra özelleştirmeler (font, buton stili vb.) buraya gelir
);
