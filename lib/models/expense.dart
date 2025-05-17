import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

enum Category {
  food,
  shopping,
  transportation,
  utilities,
  entertainment,
  health,
  education,
  other
}

// Map each category to an icon and color
extension CategoryExtension on Category {
  IconData get icon {
    switch (this) {
      case Category.food:
        return Icons.restaurant;
      case Category.shopping:
        return Icons.shopping_bag;
      case Category.transportation:
        return Icons.directions_car;
      case Category.utilities:
        return Icons.water_damage;
      case Category.entertainment:
        return Icons.movie;
      case Category.health:
        return Icons.medical_services;
      case Category.education:
        return Icons.school;
      case Category.other:
        return Icons.more_horiz;
    }
  }

  Color get color {
    switch (this) {
      case Category.food:
        return Colors.red;
      case Category.shopping:
        return Colors.blue;
      case Category.transportation:
        return Colors.green;
      case Category.utilities:
        return Colors.orange;
      case Category.entertainment:
        return Colors.purple;
      case Category.health:
        return Colors.pink;
      case Category.education:
        return Colors.teal;
      case Category.other:
        return Colors.grey;
    }
  }

  String get name {
    return toString().split('.').last;
  }
}

class Expense {
  final String id;
  final String title;
  final double amount;
  final DateTime date;
  final Category category;

  Expense({
    required this.title,
    required this.amount,
    required this.date,
    required this.category,
  }) : id = DateTime.now().toString();

  String get formattedDate {
    return DateFormat.yMd().format(date);
  }
}

class ExpenseBucket {
  final Category category;
  final List<Expense> expenses;

  ExpenseBucket({required this.category, required this.expenses});

  ExpenseBucket.forCategory(List<Expense> allExpenses, this.category)
      : expenses = allExpenses
            .where((expense) => expense.category == category)
            .toList();

  double get totalExpenses {
    double sum = 0;
    for (final expense in expenses) {
      sum += expense.amount;
    }
    return sum;
  }
} 