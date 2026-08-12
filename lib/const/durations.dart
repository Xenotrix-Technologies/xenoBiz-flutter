/// Animation and debounce duration constants.
abstract class AppDurations {
  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 300);
  static const Duration slow = Duration(milliseconds: 500);
  static const Duration pageTransition = Duration(milliseconds: 250);

  // Debouncing & Timeouts
  static const Duration searchDebounce = Duration(milliseconds: 400);
  static const Duration apiTimeout = Duration(seconds: 15);
  static const Duration toastDuration = Duration(seconds: 3);
}
