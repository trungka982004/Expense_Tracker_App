import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/expense.dart';
import 'package:expense_tracker_app/models/category.dart' as myapp;

class ExpenseProvider with ChangeNotifier {
  final List<Expense> _expenses = [];
  final List<myapp.Category> _categories = [
    myapp.Category(
      id: '1',
      name: 'Food',
      icon: Icons.restaurant,
      color: Colors.orange,
    ),
    myapp.Category(
      id: '2',
      name: 'Transportation',
      icon: Icons.directions_car,
      color: Colors.blue,
    ),
    myapp.Category(
      id: '3',
      name: 'Shopping',
      icon: Icons.shopping_bag,
      color: Colors.pink,
    ),
    myapp.Category(
      id: '4',
      name: 'Bills',
      icon: Icons.receipt_long,
      color: Colors.red,
    ),
    myapp.Category(
      id: '5',
      name: 'Entertainment',
      icon: Icons.movie,
      color: Colors.purple,
    ),
    myapp.Category(
      id: '6',
      name: 'Health',
      icon: Icons.medical_services,
      color: Colors.green,
    ),
    myapp.Category(
      id: '7',
      name: 'Education',
      icon: Icons.school,
      color: Colors.teal,
    ),
    myapp.Category(
      id: '8',
      name: 'Salary',
      icon: Icons.work,
      color: Colors.green,
    ),
    myapp.Category(
      id: '9',
      name: 'Investment',
      icon: Icons.trending_up,
      color: Colors.amber,
    ),
    myapp.Category(
      id: '10',
      name: 'Other',
      icon: Icons.more_horiz,
      color: Colors.grey,
    ),
  ];

  List<Expense> get expenses => [..._expenses];
  List<myapp.Category> get categories => [..._categories];

  double get totalExpenses {
    return _expenses.fold(0, (sum, expense) => sum + expense.amount);
  }

  double get totalIncome {
    return _expenses
        .where((expense) => expense.amount > 0)
        .fold(0, (sum, expense) => sum + expense.amount);
  }

  double get totalExpense {
    return _expenses
        .where((expense) => expense.amount < 0)
        .fold(0, (sum, expense) => sum + expense.amount.abs());
  }

  Map<myapp.Category, double> get expensesByCategory {
    final Map<myapp.Category, double> result = {};
    for (var category in _categories) {
      final total = _expenses
          .where((expense) => expense.categoryId == category.id)
          .fold(0.0, (sum, expense) => sum + expense.amount.abs());
      result[category] = total;
    }
    return result;
  }

  void addExpense({
    required String title,
    required double amount,
    required DateTime date,
    required String categoryId,
  }) {
    final newExpense = Expense(
      id: DateTime.now().toString(),
      title: title,
      amount: amount,
      date: date,
      categoryId: categoryId,
    );
    _expenses.add(newExpense);
    notifyListeners();
  }

  void deleteExpense(String id) {
    _expenses.removeWhere((expense) => expense.id == id);
    notifyListeners();
  }
} 