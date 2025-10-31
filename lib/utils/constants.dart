import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'Expense Tracker';
  static const String appVersion = '1.0.0';

  static const String income = 'income';
  static const String expense = 'expense';

  static List<Map<String, dynamic>> defaultCategories = [
    {
      'name': 'Food & Drink',
      'icon': Icons.restaurant,
      'color': Colors.orange,
      'type': expense,
    },
    {
      'name': 'Transportation',
      'icon': Icons.directions_car,
      'color': Colors.blue,
      'type': expense,
    },
    {
      'name': 'Shopping',
      'icon': Icons.shopping_bag,
      'color': Colors.purple,
      'type': expense,
    },
    {
      'name': 'Entertainment',
      'icon': Icons.movie,
      'color': Colors.pink,
      'type': expense,
    },
    {
      'name': 'Health',
      'icon': Icons.health_and_safety,
      'color': Colors.red,
      'type': expense,
    },
    {
      'name': 'Education',
      'icon': Icons.school,
      'color': Colors.indigo,
      'type': expense,
    },
    {
      'name': 'Salary',
      'icon': Icons.attach_money,
      'color': Colors.green,
      'type': income,
    },
    {
      'name': 'Gift',
      'icon': Icons.card_giftcard,
      'color': Colors.teal,
      'type': income,
    },
    {
      'name': 'Other Income',
      'icon': Icons.account_balance_wallet,
      'color': Colors.lightGreen,
      'type': income,
    },
    {
      'name': 'Other Expense',
      'icon': Icons.more_horiz,
      'color': Colors.grey,
      'type': expense,
    },
  ];
}
