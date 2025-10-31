import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../models/expense.dart';
import '../widgets/expense_item.dart';
import '../widgets/segmented_control.dart';
import '../widgets/add_expense_modal.dart';
import 'expense_detail_screen.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filterOptions = ['All', 'Today', 'Week', 'Month'];
  List<Expense> _filteredExpenses = [];
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _filterExpenses();
    });
  }

  void _filterExpenses() {
    final now = DateTime.now();
    final allExpenses = Provider.of<ExpensesProvider>(context, listen: false).expenses;

    setState(() {
      switch (_selectedFilterIndex) {
        case 1: // Today
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.year == now.year &&
                   expense.date.month == now.month &&
                   expense.date.day == now.day;
          }).toList();
          break;
        case 2: // Week
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
                   expense.date.isBefore(now.add(const Duration(days: 1)));
          }).toList();
          break;
        case 3: // Month
          final monthStart = DateTime(now.year, now.month, 1);
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                   expense.date.isBefore(DateTime(now.year, now.month + 1, 1));
          }).toList();
          break;
        case 0: // All
        default:
          _filteredExpenses = List.from(allExpenses);
          break;
      }

      // Sort expenses by date (newest first)
      _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
  }

  void _openAddExpenseModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddExpenseModal(
        onAddExpense: (expense) {
          Provider.of<ExpensesProvider>(context, listen: false)
              .addExpense(expense);
        },
      ),
    );
  }

  void _showExpenseDetail(Expense expense) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ExpenseDetailScreen(expense: expense),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'History',
          style: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            letterSpacing: -0.5,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.black, size: 24),
            onPressed: _openAddExpenseModal,
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(
            height: 1,
            color: const Color(0xFFE5E5E5),
          ),
        ),
      ),
      body: Column(
        children: [
          // Filter Section
          Padding(
            padding: const EdgeInsets.all(16),
            child: SegmentedControl(
              options: _filterOptions,
              selectedIndex: _selectedFilterIndex,
              onChanged: (index) {
                setState(() {
                  _selectedFilterIndex = index;
                });
                _filterExpenses();
              },
            ),
          ),

          // Expense List
          Expanded(
            child: Consumer<ExpensesProvider>(
              builder: (ctx, expensesProvider, _) {
                // Refresh filtered expenses when data changes
                if (_filteredExpenses.length != expensesProvider.expenses.length) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _filterExpenses();
                  });
                }

                if (_filteredExpenses.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.receipt_long,
                          size: 48,
                          color: Colors.black,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: GoogleFonts.inter(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        if (_selectedFilterIndex != 0)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Try changing the filter',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding: const EdgeInsets.only(bottom: 16),
                  itemCount: _filteredExpenses.length,
                  itemBuilder: (ctx, index) {
                    final expense = _filteredExpenses[index];
                    return GestureDetector(
                      onTap: () => _showExpenseDetail(expense),
                      child: ExpenseItem(
                        expense: expense,
                        onDelete: (id) {
                          expensesProvider.removeExpense(id);
                          _filterExpenses();
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 