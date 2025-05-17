import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';
import '../models/expense.dart';

class ImageService {
  // Export a single expense as a text file instead of an image
  // This is more reliable than dealing with screenshot package issues
  static Future<void> exportExpense(Expense expense) async {
    final dateFormatter = DateFormat.yMMMMd();
    final timeFormatter = DateFormat.jm();
    
    try {
      // Create a text file with formatted expense details
      final directory = await getTemporaryDirectory();
      final fileName = 'Expense_${expense.title.replaceAll(' ', '_')}_${DateFormat('yyyyMMdd_HHmmss').format(DateTime.now())}.txt';
      final file = File('${directory.path}/$fileName');
      
      // Format the text content with expense details
      final content = '''
===================================
          EXPENSE RECEIPT
===================================

Title:      ${expense.title}
Amount:     \$${expense.amount.toStringAsFixed(2)}
Category:   ${_capitalizeFirstLetter(expense.category.name)}
Date:       ${dateFormatter.format(expense.date)}
Time:       ${timeFormatter.format(expense.date)}

===================================
Transaction ID: ${expense.id}
Generated on: ${dateFormatter.format(DateTime.now())} at ${timeFormatter.format(DateTime.now())}
===================================
''';
      
      // Write to file and open
      await file.writeAsString(content);
      await OpenFile.open(file.path);
      
    } catch (e) {
      print('Error exporting expense: $e');
      rethrow;
    }
  }

  static String _capitalizeFirstLetter(String text) {
    if (text.isEmpty) return text;
    return text.substring(0, 1).toUpperCase() + text.substring(1);
  }
} 