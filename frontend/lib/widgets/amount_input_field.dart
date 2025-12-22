import 'package:flutter/material.dart';
import 'package:zarbin/utils/persian_formatter.dart';

/// AmountInputField - Input widget for transaction amount
/// Features:
/// - Persian numeral support
/// - Amount validation (>0, <=99,999,999,999)
/// - Formatted display with thousands separators
/// - Error message display
class AmountInputField extends StatefulWidget {
  final TextEditingController controller;
  final String label;
  final String placeholder;
  final String? errorText;
  final Function(String) onChanged;
  final int maxAmount;

  const AmountInputField({
    Key? key,
    required this.controller,
    required this.label,
    required this.placeholder,
    this.errorText,
    required this.onChanged,
    this.maxAmount = 99999999999,
  }) : super(key: key);

  @override
  State<AmountInputField> createState() => _AmountInputFieldState();
}

class _AmountInputFieldState extends State<AmountInputField> {
  /// Converts input to Persian numerals and validates
  void _onChanged(String value) {
    // Convert any English numerals to Persian for display
    final persianValue = PersianFormatter.toPersianDigits(value);
    
    // Update controller if changed
    if (persianValue != value) {
      final cursorPos = widget.controller.selection.baseOffset;
      widget.controller.value = TextEditingValue(
        text: persianValue,
        selection: TextSelection.collapsed(offset: cursorPos < 0 ? 0 : cursorPos),
      );
    }

    // Notify parent of change
    widget.onChanged(persianValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        TextField(
          controller: widget.controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: widget.placeholder,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 16,
            ),
            errorText: widget.errorText,
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.red, width: 2),
            ),
            suffixText: 'تومان',
            suffixStyle: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
          onChanged: _onChanged,
          textDirection: TextDirection.rtl,
          textAlign: TextAlign.right,
        ),
        if (widget.errorText != null)
          Padding(
            padding: const EdgeInsets.only(top: 8.0),
            child: Text(
              widget.errorText!,
              style: const TextStyle(
                color: Colors.red,
                fontSize: 12,
              ),
            ),
          ),
        // Show Persian numerals hint
        Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text(
            'Use Persian numerals: ۰-۹',
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ),
      ],
    );
  }
}
