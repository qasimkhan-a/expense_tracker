import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:open_file/open_file.dart';
import '../models/expense.dart';
import '../providers/expenses_provider.dart';

class PdfService {
  // Export a single expense to PDF
  static Future<void> exportExpense(Expense expense) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat.yMMMMd();
    final timeFormatter = DateFormat.jm();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Padding(
            padding: const pw.EdgeInsets.all(20),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text(
                      'Expense Receipt',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                      ),
                    ),
                    pw.Text(
                      'ExpenseTracker',
                      style: pw.TextStyle(
                        fontSize: 16,
                        fontWeight: pw.FontWeight.bold,
                        color: PdfColors.blue900,
                      ),
                    ),
                  ],
                ),
                pw.SizedBox(height: 20),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Center(
                  child: pw.Column(
                    children: [
                      pw.Text(
                        expense.title,
                        style: pw.TextStyle(
                          fontSize: 20,
                          fontWeight: pw.FontWeight.bold,
                        ),
                      ),
                      pw.SizedBox(height: 8),
                      pw.Text(
                        '\$${expense.amount.toStringAsFixed(2)}',
                        style: pw.TextStyle(
                          fontSize: 28,
                          fontWeight: pw.FontWeight.bold,
                          color: PdfColors.blue900,
                        ),
                      ),
                    ],
                  ),
                ),
                pw.SizedBox(height: 30),
                _buildDetailRow('Category', _capitalizeFirstLetter(expense.category.name)),
                pw.SizedBox(height: 15),
                _buildDetailRow('Date', dateFormatter.format(expense.date)),
                pw.SizedBox(height: 15),
                _buildDetailRow('Time', timeFormatter.format(expense.date)),
                pw.SizedBox(height: 15),
                _buildDetailRow('Transaction ID', expense.id),
                pw.SizedBox(height: 40),
                pw.Divider(),
                pw.SizedBox(height: 20),
                pw.Footer(
                  title: pw.Text(
                    'Generated on ${dateFormatter.format(DateTime.now())} at ${timeFormatter.format(DateTime.now())}',
                    style: const pw.TextStyle(
                      fontSize: 10,
                      color: PdfColors.grey700,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );

    // Save the PDF
    final String fileName = 'Expense_${expense.title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.pdf';
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
  }

  // Export filtered expenses to PDF
  static Future<void> exportExpenses(List<Expense> expenses, String timeRange) async {
    final pdf = pw.Document();
    final dateFormatter = DateFormat.yMMMMd();
    final now = DateTime.now();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        header: (pw.Context context) {
          return pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                '$timeRange Expense Report',
                style: pw.TextStyle(
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Text(
                'Expenso',
                style: pw.TextStyle(
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                  color: PdfColors.blue900,
                ),
              ),
            ],
          );
        },
        footer: (pw.Context context) {
          return pw.Footer(
            title: pw.Text(
              'Generated on ${dateFormatter.format(now)} | Page ${context.pageNumber} of ${context.pagesCount}',
              style: const pw.TextStyle(
                fontSize: 10,
                color: PdfColors.grey700,
              ),
            ),
          );
        },
        build: (pw.Context context) {
          // Calculate total
          final double total = expenses.fold(0, (sum, expense) => sum + expense.amount);
          
          // Group expenses by category
          final Map<String, double> categoryTotals = {};
          for (final expense in expenses) {
            final category = expense.category.name;
            if (categoryTotals.containsKey(category)) {
              categoryTotals[category] = categoryTotals[category]! + expense.amount;
            } else {
              categoryTotals[category] = expense.amount;
            }
          }
          
          return [
            pw.Padding(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'Summary',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  _buildSummaryItem('Total Expenses', '\$${total.toStringAsFixed(2)}'),
                  pw.SizedBox(height: 8),
                  _buildSummaryItem('Number of Transactions', expenses.length.toString()),
                  pw.SizedBox(height: 8),
                  _buildSummaryItem('Period', timeRange),
                  
                  pw.SizedBox(height: 20),
                  pw.Text(
                    'Category Breakdown',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  
                  // Category breakdown
                  ...categoryTotals.entries.map((entry) {
                    final percentage = (entry.value / total * 100).toStringAsFixed(1);
                    return _buildSummaryItem(
                      _capitalizeFirstLetter(entry.key),
                      '\$${entry.value.toStringAsFixed(2)} ($percentage%)',
                    );
                  }).toList(),
                  
                  pw.SizedBox(height: 20),
                  pw.Divider(),
                  pw.SizedBox(height: 20),
                  
                  pw.Text(
                    'Expense Details',
                    style: pw.TextStyle(
                      fontSize: 16,
                      fontWeight: pw.FontWeight.bold,
                    ),
                  ),
                  pw.SizedBox(height: 10),
                  
                  // Table header
                  pw.TableHelper.fromTextArray(
                    headers: ['Date', 'Title', 'Category', 'Amount'],
                    data: expenses.map((expense) => [
                      dateFormatter.format(expense.date),
                      expense.title,
                      _capitalizeFirstLetter(expense.category.name),
                      '\$${expense.amount.toStringAsFixed(2)}',
                    ]).toList(),
                    headerStyle: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColors.white,
                    ),
                    headerDecoration: const pw.BoxDecoration(
                      color: PdfColors.blue900,
                    ),
                    border: null,
                    cellHeight: 30,
                    cellAlignments: {
                      0: pw.Alignment.centerLeft,
                      1: pw.Alignment.centerLeft,
                      2: pw.Alignment.centerLeft,
                      3: pw.Alignment.centerRight,
                    },
                  ),
                ],
              ),
            ),
          ];
        },
      ),
    );

    // Save the PDF
    final String fileName = 'Expense_Report_${timeRange.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd').format(now)}.pdf';
    final output = await getTemporaryDirectory();
    final file = File('${output.path}/$fileName');
    await file.writeAsBytes(await pdf.save());

    // Open the PDF
    await OpenFile.open(file.path);
  }

  static pw.Widget _buildDetailRow(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(
          label,
          style: const pw.TextStyle(
            color: PdfColors.grey700,
          ),
        ),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildSummaryItem(String label, String value) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Text(label),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontWeight: pw.FontWeight.bold,
          ),
        ),
      ],
    );
  }

  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
} 