import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/budget_overview.dart';
import '../widgets/category_bar_chart.dart';
import '../widgets/expense_item.dart';
import '../widgets/add_expense_modal.dart';
import '../models/expense.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _openAddExpenseModal(BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Expenses',
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
            onPressed: () => _openAddExpenseModal(context),
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
      body: Consumer<ExpensesProvider>(
        builder: (ctx, expensesProvider, _) {
          final expenses = expensesProvider.expenses.take(5).toList();
          final totalExpenses = expensesProvider.totalExpenses;
          final monthlyBudget = expensesProvider.monthlyBudget;
          final remainingBudget = expensesProvider.remainingBudget;
          final expensesByCategory = expensesProvider.expensesByCategory;
          final isBudgetSet = monthlyBudget > 0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),

                // Budget Overview or Welcome Card
                if (!isBudgetSet)
                  _buildWelcomeCard(context)
                else
                  BudgetOverview(
                    monthlyBudget: monthlyBudget,
                    totalExpenses: totalExpenses,
                    remainingBudget: remainingBudget,
                  ),

                const SizedBox(height: 16),

                // Category Breakdown Section
                if (isBudgetSet && expensesByCategory.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.only(left: 24, top: 8, bottom: 12),
                    child: Text(
                      'Breakdown',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: CategoryBarChart(
                      expensesByCategory: expensesByCategory,
                      totalAmount: totalExpenses,
                      showAll: false, // Show top 4 only on home screen
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Recent Expenses Section
                if (isBudgetSet) ...[
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                    child: Text(
                      'Recent',
                      style: GoogleFonts.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),
                  ),

                  if (expenses.isEmpty)
                    _buildEmptyExpensesState()
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: expenses.length,
                      itemBuilder: (context, index) {
                        final expense = expenses[index];
                        return ExpenseItem(
                          expense: expense,
                          onDelete: (id) {
                            expensesProvider.removeExpense(id);
                          },
                        );
                      },
                    ),
                ],

                const SizedBox(height: 32),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildWelcomeCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 48,
            color: Colors.white.withOpacity(0.8),
          ),
          const SizedBox(height: 16),
          Text(
            'Set a budget',
            style: GoogleFonts.inter(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Track your spending against a monthly budget',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              // Navigate to Settings tab (index 3)
              // This will be handled by the bottom nav
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
            ),
            child: const Text('Set Budget'),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyExpensesState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(48.0),
        child: Column(
          children: [
            const Icon(
              Icons.receipt_long,
              size: 48,
              color: Colors.black,
            ),
            const SizedBox(height: 16),
            Text(
              'No expenses yet',
              style: GoogleFonts.inter(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap + to add your first expense',
              style: GoogleFonts.inter(
                fontSize: 14,
                color: const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 