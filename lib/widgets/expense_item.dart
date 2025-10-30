import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../models/expense.dart';
import '../providers/currency_provider.dart';
import '../screens/expense_detail_screen.dart';

class ExpenseItem extends StatelessWidget {
  final Expense expense;
  final Function(String) onDelete;
  final Function(Expense)? onTap;

  const ExpenseItem({
    Key? key,
    required this.expense,
    required this.onDelete,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final currencyProvider = Provider.of<CurrencyProvider>(context);

    return Slidable(
      endActionPane: ActionPane(
        motion: const ScrollMotion(),
        children: [
          SlidableAction(
            onPressed: (_) => onDelete(expense.id),
            backgroundColor: Colors.red,
            foregroundColor: Colors.white,
            icon: Icons.delete,
            borderRadius: const BorderRadius.horizontal(right: Radius.circular(12)),
          ),
        ],
      ),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: InkWell(
          onTap: () {
            if (onTap != null) {
              onTap!(expense);
            } else {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ExpenseDetailScreen(expense: expense),
                ),
              );
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              children: [
                // Left side - Title and subtitle (70%)
                Expanded(
                  flex: 70,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title
                      Text(
                        expense.title,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.black,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      // Date • Category
                      Row(
                        children: [
                          Text(
                            expense.formattedDate,
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: const Color(0xFF666666),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 6),
                            child: Text(
                              '•',
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF666666),
                              ),
                            ),
                          ),
                          // Colored dot indicator
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              color: expense.category.color,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              expense.category.name[0].toUpperCase() +
                                  expense.category.name.substring(1),
                              style: GoogleFonts.inter(
                                fontSize: 13,
                                color: const Color(0xFF666666),
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                // Right side - Amount (30%)
                Expanded(
                  flex: 30,
                  child: Text(
                    currencyProvider.formatAmount(expense.amount),
                    style: GoogleFonts.inter(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 