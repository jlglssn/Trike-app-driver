import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class PhoneNumberDisplayFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    String text = newValue.text;

    // Remove any non-numeric characters (if needed)
    text = text.replaceAll(RegExp(r'\D'), '');

    // Apply the formatting only for display (with spaces)
    StringBuffer buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      if (i == 3 || i == 6) {
        buffer.write(' '); // Add space after the 3rd and 6th digit
      }
      buffer.write(text[i]);
    }

    String formattedText = buffer.toString();
    return newValue.copyWith(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}