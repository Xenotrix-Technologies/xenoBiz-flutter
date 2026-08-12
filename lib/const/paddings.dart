import 'package:flutter/material.dart';

/// Centralized spacing and padding design tokens.
abstract class AppPadding {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;

  // Screen Padding
  static const EdgeInsets screen = EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0);
  static const EdgeInsets horizontal = EdgeInsets.symmetric(horizontal: 16.0);
  static const EdgeInsets vertical = EdgeInsets.symmetric(vertical: 16.0);

  // Component Paddings
  static const EdgeInsets card = EdgeInsets.all(16.0);
  static const EdgeInsets cardCompact = EdgeInsets.all(12.0);
  static const EdgeInsets input = EdgeInsets.symmetric(horizontal: 16.0, vertical: 14.0);
  static const EdgeInsets button = EdgeInsets.symmetric(horizontal: 24.0, vertical: 14.0);
  static const EdgeInsets chip = EdgeInsets.symmetric(horizontal: 12.0, vertical: 6.0);
  static const EdgeInsets section = EdgeInsets.only(bottom: 24.0);
}
