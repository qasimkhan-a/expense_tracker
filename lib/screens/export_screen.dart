import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/expenses_provider.dart';
import '../utilities/pdf_service.dart';

class ExportScreen extends StatefulWidget {
  const ExportScreen({Key? key}) : super(key: key);

  @override
  State<ExportScreen> createState() => _ExportScreenState();
}

class _ExportScreenState extends State<ExportScreen> {
  String _selectedTimeRange = 'Daily';
  final Map<String, String> _timeRanges = {
    'Daily': 'Today',
    'Weekly': 'This Week',
    'Monthly': 'This Month',
    'All Time': 'All Time',
  };

  Future<void> _exportReport() async {
    final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
    List<Expense> expenses = [];
    String timeRangeLabel = _timeRanges[_selectedTimeRange] ?? 'Custom';

    // Get the appropriate expenses based on the selected time range
    switch (_selectedTimeRange) {
      case 'Daily':
        expenses = expensesProvider.getTodayExpenses();
        break;
      case 'Weekly':
        expenses = expensesProvider.getWeeklyExpenses();
        break;
      case 'Monthly':
        expenses = expensesProvider.getMonthlyExpenses();
        break;
      case 'All Time':
      default:
        expenses = expensesProvider.expenses;
        break;
    }

    if (expenses.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No expenses found for the selected time range'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    try {
      await PdfService.exportExpenses(expenses, timeRangeLabel);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Report exported successfully'),
          backgroundColor: Color(0xFF1E3B70),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export report: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final int expenseCount = expensesProvider.expenses.length;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Export Reports'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3B70),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Info card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3B70).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      color: Color(0xFF1E3B70),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Export your expense reports as PDF files to keep track of your spending habits.',
                        style: TextStyle(
                          color: Colors.grey.shade800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              const Text(
                'Select Time Range',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                ),
              ),
              const SizedBox(height: 12),
              
              // Time range selection
              ...['Daily', 'Weekly', 'Monthly', 'All Time'].map((timeRange) {
                return RadioListTile<String>(
                  title: Text(timeRange),
                  subtitle: Text(_getSubtitle(timeRange, expensesProvider)),
                  value: timeRange,
                  groupValue: _selectedTimeRange,
                  activeColor: const Color(0xFF1E3B70),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _selectedTimeRange = value;
                      });
                    }
                  },
                );
              }).toList(),
              
              const SizedBox(height: 24),
              
              if (expenseCount > 0)
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton.icon(
                    onPressed: _exportReport,
                    icon: const Icon(Icons.picture_as_pdf),
                    label: const Text('Generate PDF Report'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E3B70),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                  ),
                )
              else
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        color: Colors.amber,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'No expenses available. Add some expenses to generate reports.',
                          style: TextStyle(
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getSubtitle(String timeRange, ExpensesProvider provider) {
    switch (timeRange) {
      case 'Daily':
        final expenses = provider.getTodayExpenses();
        return '${expenses.length} expenses (${expenses.isEmpty ? '\$0.00' : '\$${provider.getTotalForPeriod(expenses).toStringAsFixed(2)}'})';
      case 'Weekly':
        final expenses = provider.getWeeklyExpenses();
        return '${expenses.length} expenses (${expenses.isEmpty ? '\$0.00' : '\$${provider.getTotalForPeriod(expenses).toStringAsFixed(2)}'})';
      case 'Monthly':
        final expenses = provider.getMonthlyExpenses();
        return '${expenses.length} expenses (${expenses.isEmpty ? '\$0.00' : '\$${provider.getTotalForPeriod(expenses).toStringAsFixed(2)}'})';
      case 'All Time':
        return '${provider.expenses.length} expenses (${provider.expenses.isEmpty ? '\$0.00' : '\$${provider.totalExpenses.toStringAsFixed(2)}'})';
      default:
        return '';
    }
  }
} 