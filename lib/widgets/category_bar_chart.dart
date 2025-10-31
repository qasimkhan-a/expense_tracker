import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/expense.dart';

class CategoryBarChart extends StatefulWidget {
  final Map<Category, double> expensesByCategory;
  final double totalAmount;
  final bool showAll;

  const CategoryBarChart({
    Key? key,
    required this.expensesByCategory,
    required this.totalAmount,
    this.showAll = false,
  }) : super(key: key);

  @override
  State<CategoryBarChart> createState() => _CategoryBarChartState();
}

class _CategoryBarChartState extends State<CategoryBarChart>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.expensesByCategory.isEmpty || widget.totalAmount == 0) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            'No expenses in this period',
            style: GoogleFonts.inter(
              fontSize: 14,
              color: const Color(0xFF666666),
            ),
          ),
        ),
      );
    }

    // Sort categories by amount (highest to lowest)
    final sortedEntries = widget.expensesByCategory.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    // Limit to top 4 if showAll is false
    final displayEntries =
        widget.showAll ? sortedEntries : sortedEntries.take(4).toList();

    return Column(
      children: List.generate(displayEntries.length, (index) {
        final entry = displayEntries[index];
        final category = entry.key;
        final amount = entry.value;
        final percentage = (amount / widget.totalAmount * 100);

        // Staggered animation delay (100ms per item)
        final delay = index * 100;
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(
            delay / 800,
            1.0,
            curve: Curves.elasticOut,
          ),
        );

        return _CategoryBarItem(
          category: category,
          amount: amount,
          percentage: percentage,
          animation: animation,
        );
      }),
    );
  }
}

class _CategoryBarItem extends StatelessWidget {
  final Category category;
  final double amount;
  final double percentage;
  final Animation<double> animation;

  const _CategoryBarItem({
    Key? key,
    required this.category,
    required this.amount,
    required this.percentage,
    required this.animation,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 52,
      padding: const EdgeInsets.symmetric(vertical: 8),
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Left section: Category icon and name (fixed 100px)
          SizedBox(
            width: 100,
            child: Row(
              children: [
                Icon(
                  category.icon,
                  size: 20,
                  color: category.color,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    category.name[0].toUpperCase() + category.name.substring(1),
                    style: GoogleFonts.inter(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Middle section: Bar (flexible)
          Expanded(
            child: AnimatedBuilder(
              animation: animation,
              builder: (context, child) {
                return Stack(
                  children: [
                    // Background bar
                    Container(
                      height: 32,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    // Fill bar
                    FractionallySizedBox(
                      widthFactor: (percentage / 100) * animation.value,
                      child: Container(
                        height: 32,
                        decoration: BoxDecoration(
                          color: category.color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(width: 12),
          // Right section: Amount and percentage (fixed 80px)
          SizedBox(
            width: 80,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  '\$${amount.toStringAsFixed(0)}',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  '${percentage.toStringAsFixed(0)}%',
                  style: GoogleFonts.inter(
                    fontSize: 12,
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
