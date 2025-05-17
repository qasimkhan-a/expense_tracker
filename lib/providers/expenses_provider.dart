import 'package:flutter/material.dart';
import '../models/expense.dart';

class ExpensesProvider with ChangeNotifier {
  // Empty list of expenses by default
  final List<Expense> _expenses = [];

  // Monthly budget starts at 0 by default
  double _monthlyBudget = 0.0;

  List<Expense> get expenses => [..._expenses];
  
  double get monthlyBudget => _monthlyBudget;
  
  void setMonthlyBudget(double amount) {
    _monthlyBudget = amount;
    notifyListeners();
  }

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get remainingBudget {
    return _monthlyBudget - totalExpenses;
  }

  List<Expense> get recentExpenses {
    final now = DateTime.now();
    final oneMonthAgo = DateTime(now.year, now.month - 1, now.day);
    
    return _expenses
        .where((expense) => expense.date.isAfter(oneMonthAgo))
        .toList();
  }

  Map<Category, double> get expensesByCategory {
    final Map<Category, double> categoryMap = {};
    
    for (final expense in _expenses) {
      if (categoryMap.containsKey(expense.category)) {
        categoryMap[expense.category] = categoryMap[expense.category]! + expense.amount;
      } else {
        categoryMap[expense.category] = expense.amount;
      }
    }
    
    return categoryMap;
  }

  void addExpense(Expense expense) {
    _expenses.add(expense);
    notifyListeners();
  }

  void removeExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
  
  void clearAllExpenses() {
    _expenses.clear();
    notifyListeners();
  }
  
  // Get today's expenses
  List<Expense> getTodayExpenses() {
    final now = DateTime.now();
    return _expenses.where((expense) => 
      expense.date.year == now.year &&
      expense.date.month == now.month &&
      expense.date.day == now.day
    ).toList();
  }
  
  // Get weekly expenses
  List<Expense> getWeeklyExpenses() {
    final now = DateTime.now();
    final weekStart = now.subtract(Duration(days: now.weekday - 1));
    final weekStartDate = DateTime(weekStart.year, weekStart.month, weekStart.day);
    
    return _expenses.where((expense) => 
      expense.date.isAfter(weekStartDate.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(now.add(const Duration(days: 1)))
    ).toList();
  }
  
  // Get monthly expenses
  List<Expense> getMonthlyExpenses() {
    final now = DateTime.now();
    final monthStart = DateTime(now.year, now.month, 1);
    
    return _expenses.where((expense) => 
      expense.date.isAfter(monthStart.subtract(const Duration(days: 1))) &&
      expense.date.isBefore(DateTime(now.year, now.month + 1, 1))
    ).toList();
  }
  
  // Get expenses by category
  List<Expense> getExpensesByCategory(Category category) {
    return _expenses.where((expense) => expense.category == category).toList();
  }
  
  // Get total for a specific time period
  double getTotalForPeriod(List<Expense> periodExpenses) {
    return periodExpenses.fold(0, (sum, expense) => sum + expense.amount);
  }
} 