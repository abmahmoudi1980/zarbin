import 'package:flutter/material.dart';

/// TransactionTypeToggle - Toggle widget for selecting income or expense
/// Used in AddTransactionScreen to specify transaction type
class TransactionTypeToggle extends StatefulWidget {
  final String selectedType;
  final Function(String) onTypeChanged;

  const TransactionTypeToggle({
    Key? key,
    required this.selectedType,
    required this.onTypeChanged,
  }) : super(key: key);

  @override
  State<TransactionTypeToggle> createState() => _TransactionTypeToggleState();
}

class _TransactionTypeToggleState extends State<TransactionTypeToggle> {
  late String _localSelectedType;

  @override
  void initState() {
    super.initState();
    _localSelectedType = widget.selectedType;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(bottom: 12.0),
          child: Text(
            'Type',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ),
        Row(
          children: [
            // Expense Button
            Expanded(
              child: SegmentedButton<String>(
                segments: const <ButtonSegment<String>>[
                  ButtonSegment<String>(
                    value: 'expense',
                    label: Text('Expense'),
                    icon: Icon(Icons.remove_circle_outline),
                  ),
                  ButtonSegment<String>(
                    value: 'income',
                    label: Text('Income'),
                    icon: Icon(Icons.add_circle_outline),
                  ),
                ],
                selected: <String>{_localSelectedType},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _localSelectedType = newSelection.first;
                  });
                  widget.onTypeChanged(_localSelectedType);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}
