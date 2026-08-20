import 'dart:convert';
import 'dart:typed_data';

enum EscPosAlign { left, center, right }

/// Low-level ESC/POS Command Builder for binary thermal printer communication.
class EscPosCommandBuilder {
  final List<int> _bytes = [];

  Uint8List build() => Uint8List.fromList(_bytes);

  /// Initialize printer (ESC @)
  void initialize() {
    _bytes.addAll([0x1B, 0x40]);
  }

  /// Set text alignment (ESC a n)
  void setAlign(EscPosAlign align) {
    switch (align) {
      case EscPosAlign.left:
        _bytes.addAll([0x1B, 0x61, 0x00]);
        break;
      case EscPosAlign.center:
        _bytes.addAll([0x1B, 0x61, 0x01]);
        break;
      case EscPosAlign.right:
        _bytes.addAll([0x1B, 0x61, 0x02]);
        break;
    }
  }

  /// Toggle bold font (ESC E n)
  void setBold(bool enable) {
    _bytes.addAll([0x1B, 0x45, enable ? 0x01 : 0x00]);
  }

  /// Set text size multiplier (GS ! n)
  void setSize({bool doubleHeight = false, bool doubleWidth = false}) {
    int val = 0x00;
    if (doubleHeight && doubleWidth) {
      val = 0x11;
    } else if (doubleHeight) {
      val = 0x01;
    } else if (doubleWidth) {
      val = 0x10;
    }
    _bytes.addAll([0x1D, 0x21, val]);
  }

  /// Append string text with optional newline
  void text(String str, {bool newline = true}) {
    final cleanStr = str.replaceAll('₹', 'Rs. ');
    _bytes.addAll(latin1.encode(cleanStr));
    if (newline) {
      _bytes.addAll([0x0A]);
    }
  }

  /// Format 2-column left/right justified row for 32-column paper width
  void twoColumnRow(String left, String right, {int width = 32, bool bold = false}) {
    if (bold) setBold(true);
    final cleanLeft = left.replaceAll('₹', 'Rs. ');
    final cleanRight = right.replaceAll('₹', 'Rs. ');
    final availableSpace = width - cleanRight.length;

    if (cleanLeft.length <= availableSpace) {
      final spaces = ' ' * (availableSpace - cleanLeft.length);
      text('$cleanLeft$spaces$cleanRight');
    } else {
      text(cleanLeft);
      final spaces = ' ' * (width - cleanRight.length);
      text('$spaces$cleanRight');
    }
    if (bold) setBold(false);
  }

  /// Append horizontal dashed or solid separator line
  void line({int width = 32, String char = '-'}) {
    text(char * width);
  }

  /// Feed n blank lines (ESC d n)
  void feed(int lines) {
    _bytes.addAll([0x1B, 0x64, lines]);
  }

  /// Paper cut command (GS V n)
  void cut({bool partial = false}) {
    _bytes.addAll([0x1D, 0x56, partial ? 0x01 : 0x00]);
  }
}
