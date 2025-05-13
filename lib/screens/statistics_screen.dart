import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import 'dart:math' show max;
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import 'package:expense_tracker_app/models/category.dart' as myapp;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'This Month';

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.translate('statistics')),
        actions: [
          DropdownButton<String>(
            value: _selectedPeriod,
            items: [
              settingsProvider.language == 'vi' ? 'Tuần Này' : 'This Week',
              settingsProvider.language == 'vi' ? 'Tháng Này' : 'This Month',
              settingsProvider.language == 'vi' ? 'Năm Nay' : 'This Year',
              settingsProvider.language == 'vi' ? 'Tất Cả' : 'All Time',
            ]
                .map((period) => DropdownMenuItem(
                      value: period,
                      child: Text(period),
                    ))
                .toList(),
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedPeriod = value;
                });
              }
            },
          ),
        ],
      ),
      body: Consumer<ExpenseProvider>(
        builder: (ctx, expenseProvider, child) {
          final expenses = expenseProvider.expenses;
          if (expenses.isEmpty) {
            return Center(
              child: Text(settingsProvider.translate('no_transactions')),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildExpenseTrendChart(expenses, settingsProvider),
                const SizedBox(height: 24),
                _buildCategoryComparison(expenseProvider, settingsProvider),
                const SizedBox(height: 24),
                _buildTopExpenses(expenses, expenseProvider, settingsProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildExpenseTrendChart(List<dynamic> expenses, SettingsProvider settingsProvider) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settingsProvider.language == 'vi' ? 'Xu Hướng Chi Tiêu' : 'Expense Trend',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: LineChart(
                LineChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _generateSpots(expenses),
                      isCurved: true,
                      color: Theme.of(context).colorScheme.primary,
                      barWidth: 3,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.1),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _generateSpots(List<dynamic> expenses) {
    // Group expenses by date and calculate daily totals
    final dailyExpenses = <DateTime, double>{};
    for (var expense in expenses) {
      final date = DateTime(
        expense.date.year,
        expense.date.month,
        expense.date.day,
      );
      dailyExpenses[date] = (dailyExpenses[date] ?? 0) + expense.amount;
    }

    // Convert to spots
    final spots = dailyExpenses.entries.map((entry) {
      return FlSpot(
        entry.key.millisecondsSinceEpoch.toDouble(),
        entry.value,
      );
    }).toList();

    // Sort by date
    spots.sort((a, b) => a.x.compareTo(b.x));
    return spots;
  }

  Widget _buildCategoryComparison(ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    final expensesByCategory = expenseProvider.expensesByCategory;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settingsProvider.language == 'vi' ? 'So Sánh Danh Mục' : 'Category Comparison',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 200,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: expensesByCategory.values.isEmpty
                      ? 0
                      : expensesByCategory.values.reduce((a, b) => a > b ? a : b),
                  barTouchData: BarTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    show: true,
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final category = expensesByCategory.keys
                              .elementAt(value.toInt());
                          return Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Icon(
                              category.icon,
                              color: category.color,
                              size: 20,
                            ),
                          );
                        },
                      ),
                    ),
                    leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: expensesByCategory.entries.map((entry) {
                    return BarChartGroupData(
                      x: expensesByCategory.keys.toList().indexOf(entry.key),
                      barRods: [
                        BarChartRodData(
                          toY: entry.value,
                          color: entry.key.color,
                          width: 20,
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(4),
                          ),
                        ),
                      ],
                    );
                  }).toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopExpenses(List<dynamic> expenses, ExpenseProvider expenseProvider, SettingsProvider settingsProvider) {
    final sortedExpenses = List.from(expenses)
      ..sort((a, b) => b.amount.abs().compareTo(a.amount.abs()));
    final topExpenses = sortedExpenses.take(5).toList();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              settingsProvider.language == 'vi' ? 'Chi Tiêu Lớn Nhất' : 'Top Expenses',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ...topExpenses.map((expense) {
              final category = expenseProvider.categories
                  .firstWhere((cat) => cat.id == expense.categoryId);
              return ListTile(
                leading: CircleAvatar(
                  backgroundColor: category.color,
                  child: Icon(category.icon, color: Colors.white),
                ),
                title: Text(expense.title),
                subtitle: Text(
                  DateFormat.yMMMd().format(expense.date),
                ),
                trailing: Text(
                  settingsProvider.formatCurrency(expense.amount),
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
} 