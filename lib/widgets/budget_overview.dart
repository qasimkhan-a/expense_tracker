import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/currency_provider.dart';

class BudgetOverview extends StatefulWidget {
  final double totalExpenses;
  final double monthlyBudget;
  final double remainingBudget;

  const BudgetOverview({
    Key? key,
    required this.totalExpenses,
    required this.monthlyBudget,
    required this.remainingBudget,
  }) : super(key: key);

  @override
  State<BudgetOverview> createState() => _BudgetOverviewState();
}

class _BudgetOverviewState extends State<BudgetOverview>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _progressAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _progressAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
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
    final isOverBudget = widget.remainingBudget < 0;
    final progress = (widget.totalExpenses / widget.monthlyBudget).clamp(0.0, 1.0);
    final currencyProvider = Provider.of<CurrencyProvider>(context);

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
          // Label
          Text(
            'BUDGET',
            style: GoogleFonts.inter(
              color: Colors.white.withOpacity(0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),

          // Budget Amount
          Text(
            currencyProvider.formatAmount(widget.monthlyBudget),
            style: GoogleFonts.inter(
              color: Colors.white,
              fontSize: 42,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 20),

          // Progress Bar
          AnimatedBuilder(
            animation: _progressAnimation,
            builder: (context, child) {
              return Stack(
                children: [
                  // Background bar
                  Container(
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                    ),
                  ),
                  // Fill bar
                  FractionallySizedBox(
                    widthFactor: progress * _progressAnimation.value,
                    child: Container(
                      height: 4,
                      decoration: BoxDecoration(
                        color: isOverBudget ? const Color(0xFFEF4444) : Colors.white,
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 12),

          // Remaining text
          Text(
            isOverBudget
                ? '${currencyProvider.formatAmount(widget.remainingBudget.abs())} over'
                : '${currencyProvider.formatAmount(widget.remainingBudget)} left',
            style: GoogleFonts.inter(
              color: isOverBudget
                  ? const Color(0xFFEF4444)
                  : Colors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
} 