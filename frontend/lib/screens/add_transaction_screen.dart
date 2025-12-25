import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zarbin/providers/transaction_provider.dart';
import 'package:zarbin/providers/market_rate_provider.dart';
import 'package:zarbin/utils/persian_formatter.dart';
import 'package:zarbin/utils/jalali_helper.dart';
import 'package:zarbin/widgets/category_selector.dart';
import 'package:zarbin/widgets/transaction_type_toggle.dart';
import 'package:zarbin/widgets/amount_input_field.dart';
import 'package:zarbin/widgets/dual_currency_display.dart';
import 'package:shamsi_date/shamsi_date.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

/// AddTransactionScreen - Allows users to create income/expense transactions
/// Features:
/// - Income/expense type toggle
/// - Amount input with Persian numeral support
/// - Category selector with all 7 categories
/// - Jalali date picker
/// - Optional notes field
/// - Dual-currency display (Toman + USD equivalent)
class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({Key? key}) : super(key: key);

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  late TextEditingController _amountController;
  late TextEditingController _notesController;
  late TextEditingController _dateController;

  String _selectedType = 'expense';
  int? _selectedCategoryId;
  String? _selectedDate;
  String? _amountError;
  String? _dateError;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _notesController = TextEditingController();
    _dateController = TextEditingController();
    _selectedDate = JalaliHelper.formatFullDate(Jalali.now());
    _dateController.text = _selectedDate ?? '';
  }

  @override
  void dispose() {
    _amountController.dispose();
    _notesController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  /// Validates and submits the transaction form
  void _submitTransaction() async {
    // Validate amount
    final amountText = PersianFormatter.toEnglish(_amountController.text);
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      setState(() {
        _amountError = AppLocalizations.of(context)!.amountMustBeGreaterThanZero;
      });
      return;
    }

    if (amount > 99999999999) {
      setState(() {
        _amountError = AppLocalizations.of(context)!.amountExceedsMaximum;
      });
      return;
    }

    // Validate category
    if (_selectedCategoryId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.pleaseSelectCategory)),
      );
      return;
    }

    // Validate date
    if (_selectedDate == null || _selectedDate!.isEmpty) {
      setState(() {
        _dateError = AppLocalizations.of(context)!.pleaseSelectDate;
      });
      return;
    }

    // Submit transaction
    final provider = context.read<TransactionProvider>();
    final notes = _notesController.text.isEmpty ? null : _notesController.text;

    final success = await provider.addTransaction(
      amount: amount,
      type: _selectedType,
      categoryId: _selectedCategoryId!,
      date: _selectedDate!,
      notes: notes,
    );

    if (success) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.transactionCreatedSuccessfully)),
        );
        Navigator.of(context).pop();
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(provider.error ?? AppLocalizations.of(context)!.failedToCreateTransaction)),
        );
      }
    }
  }

  /// Opens Jalali date picker
  void _selectDate() async {
    final Jalali? picked = await showPersianDatePicker(
      context: context,
      initialDate: Jalali.now(),
      firstDate: Jalali(1300),
      lastDate: Jalali.now(),
    );

    if (picked != null) {
      setState(() {
        _selectedDate = JalaliHelper.formatFullDate(picked);
        _dateController.text = _selectedDate!;
        _dateError = null;
      });
    }
  }

  /// Calculates USD equivalent of entered amount
  String _calculateUsdEquivalent() {
    final amountText = PersianFormatter.toEnglish(_amountController.text);
    final amount = int.tryParse(amountText);

    if (amount == null || amount <= 0) {
      return '0 USD';
    }

    final rateProvider = context.read<MarketRateProvider>();
    final usdRate = rateProvider.currentUsdRate;
    if (usdRate <= 0) return '0 USD';

    final usdEquivalent = amount / usdRate;

    return '${usdEquivalent.toStringAsFixed(2)} USD';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
       appBar: AppBar(
         title: Text(AppLocalizations.of(context)!.addTransaction),
         centerTitle: true,
       ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Transaction Type Toggle (T095)
            TransactionTypeToggle(
              selectedType: _selectedType,
              onTypeChanged: (newType) {
                setState(() {
                  _selectedType = newType;
                });
              },
            ),
            const SizedBox(height: 24.0),

            // Amount Input Field with Persian numeral support (T086, T094)
            AmountInputField(
              controller: _amountController,
              label: AppLocalizations.of(context)!.amount,
              placeholder: AppLocalizations.of(context)!.enterAmountInToman,
              errorText: _amountError,
              onChanged: (_) {
                setState(() {
                  _amountError = null;
                });
              },
            ),
            const SizedBox(height: 12.0),

            // Dual Currency Display (T092)
            DualCurrencyDisplay(
              amountToman: int.tryParse(
                    PersianFormatter.toEnglish(_amountController.text),
                  ) ??
                  0,
              usdEquivalent: _calculateUsdEquivalent(),
            ),
            const SizedBox(height: 24.0),

            // Category Selector (T088)
            CategorySelector(
              selectedCategoryId: _selectedCategoryId,
              onCategorySelected: (categoryId) {
                setState(() {
                  _selectedCategoryId = categoryId;
                });
              },
            ),
            const SizedBox(height: 24.0),

            // Jalali Date Picker (T087)
            TextField(
              controller: _dateController,
              readOnly: true,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.date,
                hintText: AppLocalizations.of(context)!.selectDate,
                border: const OutlineInputBorder(),
                errorText: _dateError,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.calendar_today),
                  onPressed: _selectDate,
                ),
              ),
              onTap: _selectDate,
            ),
            const SizedBox(height: 24.0),

            // Notes Field
            TextField(
              controller: _notesController,
              maxLines: 3,
              maxLength: 500,
              decoration: InputDecoration(
                labelText: AppLocalizations.of(context)!.notes,
                hintText: AppLocalizations.of(context)!.optionalNotes,
                border: const OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
            const SizedBox(height: 32.0),

            // Submit Button
            Consumer<TransactionProvider>(
              builder: (context, provider, _) {
                return ElevatedButton(
                  onPressed: provider.isLoading ? null : _submitTransaction,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16.0),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                       : Text(AppLocalizations.of(context)!.saveTransaction),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper function to show Jalali date picker
/// Uses shamsi_date package for Persian calendar support
Future<Jalali?> showPersianDatePicker({
  required BuildContext context,
  required Jalali initialDate,
  required Jalali firstDate,
  required Jalali lastDate,
}) async {
  return showDatePicker(
    context: context,
    initialDate: initialDate.toDateTime(),
    firstDate: firstDate.toDateTime(),
    lastDate: lastDate.toDateTime(),
  ).then((dateTime) {
    if (dateTime != null) {
      return Jalali.fromDateTime(dateTime);
    }
    return null;
  });
}
