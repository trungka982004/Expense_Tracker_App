import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import 'package:flutter/services.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final expenseProvider = Provider.of<ExpenseProvider>(context);
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final allExpenses = expenseProvider.expenses.reversed.toList();
    final balance = expenseProvider.totalExpenses;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    List filteredExpenses;
    if (_tabController.index == 1) {
      filteredExpenses = allExpenses.where((e) => e.amount < 0).toList();
    } else if (_tabController.index == 2) {
      filteredExpenses = allExpenses.where((e) => e.amount > 0).toList();
    } else {
      filteredExpenses = allExpenses;
    }

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFF0A174E),
        body: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Transactions',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.person, color: Color(0xFF274B8C)),
                    ),
                  ],
                ),
              ),
              // Balance Card
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(18),
                    gradient: const LinearGradient(
                      colors: [Color(0xFF7F53AC), Color(0xFF647DEE)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'My Balance',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.8),
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              settingsProvider.formatCurrency(balance),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 22),
                      ],
                    ),
                  ),
                ),
              ),
              // Tab Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: Colors.white54,
                  indicator: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blueAccent.withOpacity(0.4),
                  ),
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Expense'),
                    Tab(text: 'Income'),
                  ],
                  onTap: (_) => setState(() {}),
                ),
              ),
              const SizedBox(height: 8),
              // Transaction List
              Expanded(
                child: filteredExpenses.isEmpty
                    ? Center(
                        child: Text(
                          settingsProvider.translate('no_transactions'),
                          style: const TextStyle(color: Colors.white54),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        itemCount: filteredExpenses.length,
                        itemBuilder: (ctx, i) {
                          final expense = filteredExpenses[i];
                          final category = expenseProvider.categories.firstWhere((cat) => cat.id == expense.categoryId);
                          final isExpense = expense.amount < 0;
                          final isIncome = expense.amount > 0;
                          return Card(
                            color: const Color(0xFF1B3358),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            margin: const EdgeInsets.symmetric(vertical: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.white,
                                child: Icon(category.icon, color: const Color(0xFF274B8C)),
                              ),
                              title: Text(
                                expense.title,
                                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                              subtitle: Text(
                                '${expense.date.day.toString().padLeft(2, '0')} ${_monthName(expense.date.month)} ${expense.date.year}',
                                style: const TextStyle(color: Colors.white54),
                              ),
                              trailing: Text(
                                settingsProvider.formatCurrency(expense.amount),
                                style: TextStyle(
                                  color: isExpense
                                      ? Colors.red
                                      : isIncome
                                          ? Colors.green
                                          : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _monthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }
} 