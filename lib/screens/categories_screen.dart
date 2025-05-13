import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import 'package:expense_tracker_app/models/category.dart' as myapp;
import 'package:flutter/services.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        appBar: AppBar(
          title: Text(settingsProvider.translate('categories')),
          actions: [
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: () {
                // TODO: Implement add category functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(settingsProvider.language == 'vi'
                        ? 'Chức năng thêm danh mục sẽ sớm có!' : 'Add category functionality coming soon!'),
                  ),
                );
              },
            ),
          ],
        ),
        body: Consumer<ExpenseProvider>(
          builder: (ctx, expenseProvider, child) {
            final categories = expenseProvider.categories;
            final expensesByCategory = expenseProvider.expensesByCategory;
            final totalExpenses = expenseProvider.totalExpenses;

            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: categories.length,
              itemBuilder: (ctx, index) {
                final category = categories[index];
                final categoryExpenses = expensesByCategory[category] ?? 0;
                final percentage = totalExpenses > 0
                    ? (categoryExpenses / totalExpenses) * 100
                    : 0.0;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor: category.color,
                              child: Icon(category.icon, color: Colors.white),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    category.name,
                                    style: Theme.of(context).textTheme.titleMedium,
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    settingsProvider.formatCurrency(categoryExpenses),
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .primary,
                                        ),
                                  ),
                                ],
                              ),
                            ),
                            Text(
                              '${percentage.toStringAsFixed(1)}%',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: percentage / 100,
                            backgroundColor: category.color.withOpacity(0.2),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              category.color,
                            ),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
} 