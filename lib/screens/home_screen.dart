import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expenses_provider.dart';
import '../widgets/budget_overview.dart';
import '../widgets/expense_chart.dart';
import '../widgets/expense_item.dart';
import '../widgets/add_expense_modal.dart';
import '../models/expense.dart';
import 'settings_screen.dart';
import 'history_screen.dart';
import 'export_screen.dart';
import 'expense_detail_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  void _openAddExpenseModal(BuildContext context) {
    final expensesProvider = Provider.of<ExpensesProvider>(context, listen: false);
    
    // Check if budget is set
    if (expensesProvider.monthlyBudget <= 0) {
      // Show dialog prompting to set budget first
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Set Budget First'),
          content: const Text('Please set a monthly budget before adding expenses. This helps you track your spending against your budget.'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const SettingsScreen()),
                );
              },
              child: const Text('Go to Settings'),
            ),
          ],
        ),
      );
      return;
    }
    
    // If budget is set, proceed with showing the add expense modal
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

  void _showMoreOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Options',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3B70),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ListTile(
              leading: const Icon(Icons.settings, color: Color(0xFF1E3B70)),
              title: const Text('Settings'),
              subtitle: const Text('Manage budget and app preferences'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const SettingsScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.history, color: Color(0xFF1E3B70)),
              title: const Text('Expense History'),
              subtitle: const Text('View and filter past expenses'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const HistoryScreen()),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3B70)),
              title: const Text('Export Reports'),
              subtitle: const Text('Generate PDF reports and exports'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (ctx) => const ExportScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Consumer<ExpensesProvider>(
        builder: (ctx, expensesProvider, _) {
          final expenses = expensesProvider.expenses;
          final totalExpenses = expensesProvider.totalExpenses;
          final monthlyBudget = expensesProvider.monthlyBudget;
          final remainingBudget = expensesProvider.remainingBudget;
          final expensesByCategory = expensesProvider.expensesByCategory;
          final isBudgetSet = monthlyBudget > 0;

          return SafeArea(
            child: CustomScrollView(
              slivers: [
                SliverAppBar(
                  floating: true,
                  pinned: true,
                  backgroundColor: Colors.white,
                  elevation: 0,
                  expandedHeight: 100,
                  actions: [
                    IconButton(
                      icon: const Icon(Icons.more_vert),
                      onPressed: () => _showMoreOptions(context),
                    ),
                  ],
                  flexibleSpace: FlexibleSpaceBar(
                    title: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF1E3B70),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.account_balance_wallet,
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'ExpenseTracker',
                          style: TextStyle(
                            color: Color(0xFF1E3B70),
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                          ),
                        ),
                      ],
                    ),
                    centerTitle: true,
                  ),
                ),
                SliverToBoxAdapter(
                  child: !isBudgetSet
                      ? Container(
                          margin: const EdgeInsets.all(16),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF1E3B70), Color(0xFF29539B)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF1E3B70).withOpacity(0.3),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Welcome to ExpenseTracker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Set your monthly budget to get started tracking your expenses',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => const SettingsScreen(),
                                    ),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white,
                                  foregroundColor: const Color(0xFF1E3B70),
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 24,
                                  ),
                                ),
                                child: const Text('Set Budget'),
                              ),
                            ],
                          ),
                        )
                      : BudgetOverview(
                          monthlyBudget: monthlyBudget,
                          totalExpenses: totalExpenses,
                          remainingBudget: remainingBudget,
                        ),
                ),
                !isBudgetSet || expenses.isEmpty
                    ? const SliverToBoxAdapter(child: SizedBox.shrink())
                    : SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 16,
                            right: 16,
                            top: 16,
                            bottom: 8,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Recent Transactions',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18,
                                  color: Color(0xFF1E3B70),
                                ),
                              ),
                              TextButton.icon(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (ctx) => const HistoryScreen(),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.history,
                                  size: 18,
                                ),
                                label: const Text('See All'),
                                style: TextButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E3B70),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                !isBudgetSet 
                    ? SliverFillRemaining(
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(32.0),
                            child: SingleChildScrollView(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.account_balance_wallet_outlined,
                                    size: 80,
                                    color: Colors.grey.shade400,
                                  ),
                                  const SizedBox(height: 24),
                                  Text(
                                    'Start your financial journey',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.grey.shade700,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    'Set a monthly budget to begin tracking your expenses and see insights about your spending habits.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      )
                    : expenses.isEmpty
                        ? SliverFillRemaining(
                            child: Center(
                              child: SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.receipt_long,
                                      size: 64,
                                      color: Colors.grey.shade400,
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'No expenses yet',
                                      style: TextStyle(
                                        fontSize: 18,
                                        color: Colors.grey.shade600,
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Add your first expense using the + button',
                                      style: TextStyle(
                                        fontSize: 14,
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          )
                        : SliverList(
                            delegate: SliverChildBuilderDelegate(
                              (context, index) {
                                final expense = expenses[index];
                                return GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (ctx) => ExpenseDetailScreen(expense: expense),
                                      ),
                                    );
                                  },
                                  child: ExpenseItem(
                                    expense: expense,
                                    onDelete: (id) {
                                      expensesProvider.removeExpense(id);
                                    },
                                  ),
                                );
                              },
                              childCount: expenses.length > 5 ? 5 : expenses.length,
                            ),
                          ),
                SliverToBoxAdapter(
                  child: const SizedBox(height: 80),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openAddExpenseModal(context),
        backgroundColor: const Color(0xFF1E3B70),
        child: const Icon(Icons.add),
      ),
    );
  }
} 