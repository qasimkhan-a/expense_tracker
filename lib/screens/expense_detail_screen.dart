import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/expense.dart';
import '../utilities/pdf_service.dart';
import '../utilities/image_service.dart';

class ExpenseDetailScreen extends StatelessWidget {
  final Expense expense;

  const ExpenseDetailScreen({
    Key? key,
    required this.expense,
  }) : super(key: key);

  Future<void> _exportAsPdf(BuildContext context) async {
    try {
      await PdfService.exportExpense(expense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('PDF exported successfully'),
          backgroundColor: Color(0xFF1E3B70),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export PDF: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _exportAsText(BuildContext context) async {
    try {
      await ImageService.exportExpense(expense);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text file exported successfully'),
          backgroundColor: Color(0xFF1E3B70),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to export text file: ${e.toString()}'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showExportOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Export Options',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E3B70),
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.picture_as_pdf, color: Color(0xFF1E3B70)),
              title: const Text('Export as PDF'),
              onTap: () {
                Navigator.pop(context);
                _exportAsPdf(context);
              },
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.text_snippet, color: Color(0xFF1E3B70)),
              title: const Text('Export as Text File'),
              onTap: () {
                Navigator.pop(context);
                _exportAsText(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat.yMMMMd();
    final timeFormat = DateFormat.jm();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Expense Details'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1E3B70),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.ios_share),
            onPressed: () => _showExportOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: expense.category.color.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      expense.category.icon,
                      color: expense.category.color,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    expense.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '\$${expense.amount.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3B70),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Details',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3B70),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildDetailRow(
                        'Category',
                        expense.category.name.substring(0, 1).toUpperCase() +
                            expense.category.name.substring(1),
                        expense.category.color,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Date',
                        dateFormat.format(expense.date),
                        Colors.grey.shade700,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Time',
                        timeFormat.format(expense.date),
                        Colors.grey.shade700,
                      ),
                      const Divider(height: 24),
                      _buildDetailRow(
                        'Transaction ID',
                        expense.id.substring(0, 8),
                        Colors.grey.shade700,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade600,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }
} 