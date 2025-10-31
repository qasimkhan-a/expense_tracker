import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../providers/currency_provider.dart';
import '../widgets/segmented_control.dart';
import '../widgets/category_bar_chart.dart';
import '../models/expense.dart';

class AnalyticsScreen extends StatefulWidget {
  const AnalyticsScreen({Key? key}) : super(key: key);

  @override
  State<AnalyticsScreen> createState() => _AnalyticsScreenState();
}

class _AnalyticsScreenState extends State<AnalyticsScreen> {
  int _selectedPeriodIndex = 1; // Default to Month
  final List<String> _periodOptions = ['Week', 'Month', 'Year', 'All'];

  List<Expense> _getFilteredExpenses(ExpensesProvider provider) {
    switch (_selectedPeriodIndex) {
      case 0: // Week
        return provider.getWeeklyExpenses();
      case 1: // Month
        return provider.getMonthlyExpenses();
      case 2: // Year
        // For simplicity, using all expenses for "Year" (can be enhanced)
        return provider.recentExpenses;
      case 3: // All
        return provider.recentExpenses;
      default:
        return provider.getMonthlyExpenses();
    }
  }

  @override
  Widget build(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context);
    final currencyProvider = Provider.of<CurrencyProvider>(context);
    final filteredExpenses = _getFilteredExpenses(expensesProvider);
    final totalAmount = expensesProvider.getTotalForPeriod(filteredExpenses);

    // Calculate expenses by category for filtered period
    final expensesByCategory = <Category, double>{};
    for (var expense in filteredExpenses) {
      expensesByCategory[expense.category] =
          (expensesByCategory[expense.category] ?? 0) + expense.amount;
    }

    // Get top category
    final topCategory = expensesByCategory.entries.isEmpty
        ? null
        : expensesByCategory.entries.reduce((a, b) => a.value > b.value ? a : b);

    // Calculate average per day
    final daysInPeriod = _selectedPeriodIndex == 0
        ? 7
        : _selectedPeriodIndex == 1
            ? 30
            : _selectedPeriodIndex == 2
                ? 365
                : filteredExpenses.isEmpty
                    ? 1
                    : DateTime.now().difference(filteredExpenses.last.date).inDays + 1;
    final avgPerDay = totalAmount / daysInPeriod;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Analytics',
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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Time Period Selector
              SegmentedControl(
                options: _periodOptions,
                selectedIndex: _selectedPeriodIndex,
                onChanged: (index) {
                  setState(() {
                    _selectedPeriodIndex = index;
                  });
                },
              ),
              const SizedBox(height: 24),

              // Summary Cards Row
              Row(
                children: [
                  // Total Spent Card
                  Expanded(
                    child: _SummaryCard(
                      label: 'TOTAL SPENT',
                      amount: currencyProvider.formatAmount(totalAmount),
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Average Per Day Card
                  Expanded(
                    child: _SummaryCard(
                      label: 'AVG PER DAY',
                      amount: currencyProvider.formatAmount(avgPerDay),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // Category Breakdown Section
              Text(
                'Category Breakdown',
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const SizedBox(height: 16),
              CategoryBarChart(
                expensesByCategory: expensesByCategory,
                totalAmount: totalAmount,
                showAll: true,
              ),
              const SizedBox(height: 32),

              // Top Category Section
              if (topCategory != null) ...[
                Text(
                  'Top Category This ${_periodOptions[_selectedPeriodIndex]}',
                  style: GoogleFonts.inter(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 16),
                _TopCategoryCard(
                  category: topCategory.key,
                  amount: topCategory.value,
                  percentage: (topCategory.value / totalAmount * 100),
                  currencySymbol: currencyProvider.currencySymbol,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final String label;
  final String amount;

  const _SummaryCard({
    Key? key,
    required this.label,
    required this.amount,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: GoogleFonts.inter(
              fontSize: 11,
              fontWeight: FontWeight.w500,
              color: const Color(0xFF666666),
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: GoogleFonts.inter(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class _TopCategoryCard extends StatelessWidget {
  final Category category;
  final double amount;
  final double percentage;
  final String currencySymbol;

  const _TopCategoryCard({
    Key? key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.currencySymbol,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: category.color.withOpacity(0.1),
        border: Border.all(color: category.color, width: 1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            category.icon,
            size: 32,
            color: category.color,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  category.name[0].toUpperCase() + category.name.substring(1),
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$currencySymbol${amount.toStringAsFixed(2)} • ${percentage.toStringAsFixed(0)}% of total',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: const Color(0xFF666666),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
