import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/currency_provider.dart';
import '../utilities/pdf_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _budgetController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String? _selectedCurrency;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budget = Provider.of<ExpensesProvider>(context, listen: false).monthlyBudget;
      _budgetController.text = budget > 0 ? budget.toString() : '';

      _selectedCurrency = Provider.of<CurrencyProvider>(context, listen: false).currencyCode;
    });
  }

  @override
  void dispose() {
    _budgetController.dispose();
    super.dispose();
  }

  void _updateBudget() {
    if (_formKey.currentState!.validate()) {
      final newBudget = double.parse(_budgetController.text);
      Provider.of<ExpensesProvider>(context, listen: false).setMonthlyBudget(newBudget);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Budget updated successfully', style: GoogleFonts.inter()),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _updateCurrency(String currencyCode) {
    setState(() {
      _selectedCurrency = currencyCode;
    });
    Provider.of<CurrencyProvider>(context, listen: false).setCurrency(currencyCode);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Currency changed to $currencyCode', style: GoogleFonts.inter()),
        backgroundColor: Colors.black,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _exportReport(String period) async {
    final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
    List expenses = [];
    String label = '';

    if (period == 'month') {
      expenses = expensesProvider.getMonthlyExpenses();
      label = 'This Month';
    } else {
      expenses = expensesProvider.expenses;
      label = 'All Time';
    }

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No expenses found', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await PdfService.exportExpenses(expenses, label);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Report exported successfully', style: GoogleFonts.inter()),
          backgroundColor: Colors.black,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Export failed: ${e.toString()}', style: GoogleFonts.inter()),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _clearAllExpenses() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Clear All Expenses', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
        content: Text(
          'Are you sure you want to delete all expenses? This action cannot be undone.',
          style: GoogleFonts.inter(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel', style: GoogleFonts.inter()),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExpensesProvider>(context, listen: false).clearAllExpenses();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('All expenses cleared', style: GoogleFonts.inter()),
                  backgroundColor: Colors.black,
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: Text('Delete All', style: GoogleFonts.inter(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final availableCurrencies = currencyProvider.availableCurrencies;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Settings',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // BUDGET Section
            _buildSectionTitle('BUDGET'),
            const SizedBox(height: 12),
            TextFormField(
              controller: _budgetController,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
              ],
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              decoration: InputDecoration(
                hintText: 'Enter monthly budget',
                hintStyle: GoogleFonts.inter(
                  color: const Color(0xFF999999),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a budget amount';
                }
                try {
                  final amount = double.parse(value);
                  if (amount <= 0) {
                    return 'Please enter a value greater than zero';
                  }
                } catch (e) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateBudget,
                child: Text('Save Budget', style: GoogleFonts.inter(fontWeight: FontWeight.w600)),
              ),
            ),
            const SizedBox(height: 32),

            // CURRENCY Section
            _buildSectionTitle('CURRENCY'),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: _selectedCurrency,
              style: GoogleFonts.inter(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
              decoration: const InputDecoration(),
              items: availableCurrencies.entries.map((entry) {
                return DropdownMenuItem<String>(
                  value: entry.key,
                  child: Text('${entry.value} ${entry.key}'),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  _updateCurrency(value);
                }
              },
            ),
            const SizedBox(height: 32),

            // EXPORT Section
            _buildSectionTitle('EXPORT'),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _exportReport('month'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Export This Month to PDF',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton(
              onPressed: () => _exportReport('all'),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1),
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Export All Time to PDF',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),

            // DATA Section
            _buildSectionTitle('DATA'),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearAllExpenses,
              style: TextButton.styleFrom(
                foregroundColor: Colors.red,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Clear All Expenses',
                style: GoogleFonts.inter(fontWeight: FontWeight.w500),
              ),
            ),
            const SizedBox(height: 32),

            // About Section
            Center(
              child: Text(
                'Version 1.0.0',
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: const Color(0xFF666666),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: const Color(0xFF666666),
        letterSpacing: 1.5,
      ),
    );
  }
}
