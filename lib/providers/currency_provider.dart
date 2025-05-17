import 'package:flutter/material.dart';

class CurrencyProvider with ChangeNotifier {
  // Default currency is USD
  String _currencySymbol = '\$';
  String _currencyCode = 'USD';
  
  // Available currencies
  final Map<String, String> _availableCurrencies = {
    'USD': '\$',
    'EUR': '€',
    'PKR': 'Rs',
    'AED': 'د.إ',
    'INR': '₹',
    'CAD': 'CA\$',
    'AUD': 'A\$',
    'CNY': '¥',
  };
  
  // Getters
  String get currencySymbol => _currencySymbol;
  String get currencyCode => _currencyCode;
  Map<String, String> get availableCurrencies => _availableCurrencies;
  
  // Set currency using currency code
  void setCurrency(String code) {
    if (_availableCurrencies.containsKey(code)) {
      _currencyCode = code;
      _currencySymbol = _availableCurrencies[code]!;
      notifyListeners();
    }
  }
  
  // Format amount with current currency symbol
  String formatAmount(double amount) {
    return '$_currencySymbol${amount.toStringAsFixed(2)}';
  }
} 