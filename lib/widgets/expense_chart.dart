import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/expense.dart';

class ExpenseChart extends StatelessWidget {
  final Map<Category, double> expenseData;
  final double totalExpenses;

  const ExpenseChart({
    Key? key,
    required this.expenseData,
    required this.totalExpenses,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (expenseData.isEmpty || totalExpenses == 0) {
      return const Center(
        child: Text('No expense data available'),
      );
    }

    return Container(
      height: 200,
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: PieChart(
        PieChartData(
          sectionsSpace: 2,
          centerSpaceRadius: 40,
          sections: expenseData.entries.map((entry) {
            final Category category = entry.key;
            final double value = entry.value;
            final double percentage = (value / totalExpenses) * 100;
            
            return PieChartSectionData(
              color: category.color.withOpacity(0.8),
              value: value,
              title: '${percentage.toStringAsFixed(0)}%',
              radius: 100,
              titleStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              badgeWidget: _Badge(
                category.icon,
                size: 40,
                borderColor: category.color,
              ),
              badgePositionPercentageOffset: .98,
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final double size;
  final Color borderColor;

  const _Badge(
    this.icon, {
    required this.size,
    required this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: PieChart.defaultDuration,
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        border: Border.all(
          color: borderColor,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            offset: const Offset(0, 1),
            blurRadius: 3,
          ),
        ],
      ),
      child: Center(
        child: Icon(
          icon,
          color: borderColor,
          size: 16,
        ),
      ),
    );
  }
} 