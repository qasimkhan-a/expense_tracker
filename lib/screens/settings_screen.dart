import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/currency_provider.dart';

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
    // Initialize the text field with the current budget
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final budget = Provider.of<ExpensesProvider>(context, listen: false).monthlyBudget;
      _budgetController.text = budget.toString();
      
      // Initialize selected currency
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
        const SnackBar(
          content: Text('Budget updated successfully'),
          backgroundColor: Color(0xFF1E3B70),
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
        content: Text('Currency changed to $currencyCode'),
        backgroundColor: const Color(0xFF1E3B70),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearAllExpenses() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear All Expenses'),
        content: const Text('Are you sure you want to delete all expenses? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Provider.of<ExpensesProvider>(context, listen: false).clearAllExpenses();
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All expenses cleared'),
                  backgroundColor: Color(0xFF1E3B70),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            },
            style: TextButton.styleFrom(
              foregroundColor: Colors.red,
            ),
            child: const Text('Delete All'),
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
        title: const Text('Settings'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3B70),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text(
                'Monthly Budget',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _budgetController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
                ],
                decoration: InputDecoration(
                  labelText: 'Budget Amount',
                  prefixIcon: Icon(Icons.attach_money, color: Theme.of(context).primaryColor),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.save,
                      color: Color(0xFF1E3B70),
                    ),
                    onPressed: _updateBudget,
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
              const SizedBox(height: 32),
              const Text(
                'Currency Settings',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select Currency',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      DropdownButtonFormField<String>(
                        value: _selectedCurrency,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        ),
                        items: availableCurrencies.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Row(
                              children: [
                                Text(entry.value, style: const TextStyle(fontSize: 18)),
                                const SizedBox(width: 8),
                                Text(entry.key),
                              ],
                            ),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            _updateCurrency(value);
                          }
                        },
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Current currency: ${currencyProvider.currencySymbol} (${currencyProvider.currencyCode})',
                        style: TextStyle(
                          color: Colors.grey.shade700,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Data Management',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                ),
              ),
              const SizedBox(height: 12),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
                child: ListTile(
                  leading: const Icon(
                    Icons.delete_forever,
                    color: Colors.red,
                  ),
                  title: const Text('Clear All Expenses'),
                  subtitle: const Text('This will delete all your expense records'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: _clearAllExpenses,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 