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
      switch (_selectedFilter) {
        case 'Today':
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.year == now.year &&
                   expense.date.month == now.month &&
                   expense.date.day == now.day;
          }).toList();
          break;
        case 'This Week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
                   expense.date.isBefore(now.add(const Duration(days: 1)));
          }).toList();
          break;
        case 'This Month':
          final monthStart = DateTime(now.year, now.month, 1);
          _filteredExpenses = allExpenses.where((expense) {
            return expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
                   expense.date.isBefore(DateTime(now.year, now.month + 1, 1));
          }).toList();
          break;
        case 'All':
        default:
          _filteredExpenses = List.from(allExpenses);
          break;
      }
      
      // Sort expenses by date (newest first)
      _filteredExpenses.sort((a, b) => b.date.compareTo(a.date));
    });
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
        title: const Text('Expense History'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3B70),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            color: Colors.white,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Filter',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF1E3B70),
                  ),
                ),
                const SizedBox(height: 8),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildFilterChip('All'),
                      _buildFilterChip('Today'),
                      _buildFilterChip('This Week'),
                      _buildFilterChip('This Month'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
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
                        Icon(
                          Icons.history,
                          size: 64,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No expenses found',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        if (_selectedFilter != 'All')
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(
                              'Try changing the filter',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey.shade500,
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

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              _selectedFilter = label;
            });
            _filterExpenses();
          }
        },
        backgroundColor: Colors.grey.shade200,
        selectedColor: const Color(0xFF1E3B70).withOpacity(0.2),
        checkmarkColor: const Color(0xFF1E3B70),
        labelStyle: TextStyle(
          color: isSelected ? const Color(0xFF1E3B70) : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }
} 