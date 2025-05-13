import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/expense_provider.dart';
import '../providers/settings_provider.dart';
import 'package:expense_tracker_app/models/category.dart' as myapp;

class AddTransactionScreen extends StatefulWidget {
  const AddTransactionScreen({super.key});

  @override
  State<AddTransactionScreen> createState() => _AddTransactionScreenState();
}

class _AddTransactionScreenState extends State<AddTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _amountController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  myapp.Category? _selectedCategory;
  bool _isExpense = true;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  void _submitForm() {
    if (_formKey.currentState!.validate() && _selectedCategory != null) {
      final amount = double.parse(_amountController.text);
      final finalAmount = _isExpense ? -amount : amount;

      Provider.of<ExpenseProvider>(context, listen: false).addExpense(
        title: _titleController.text,
        amount: finalAmount,
        date: _selectedDate,
        categoryId: _selectedCategory!.id,
      );

      Navigator.of(context).pop();
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsProvider = Provider.of<SettingsProvider>(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(settingsProvider.translate('add_transaction')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Transaction Type Toggle
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: Text(settingsProvider.translate('expense')),
                          selected: _isExpense,
                          onSelected: (selected) {
                            setState(() {
                              _isExpense = selected;
                            });
                          },
                        ),
                      ),
                      Expanded(
                        child: ChoiceChip(
                          label: Text(settingsProvider.translate('income')),
                          selected: !_isExpense,
                          onSelected: (selected) {
                            setState(() {
                              _isExpense = !selected;
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Title Field
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: settingsProvider.translate('title'),
                  border: const OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return settingsProvider.translate('please_enter_title');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Amount Field
              TextFormField(
                controller: _amountController,
                decoration: InputDecoration(
                  labelText: settingsProvider.translate('amount'),
                  border: const OutlineInputBorder(),
                  prefixText: settingsProvider.currency == 'VND' ? '₫ ' : '\$ ',
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return settingsProvider.translate('please_enter_amount');
                  }
                  if (double.tryParse(value) == null) {
                    return settingsProvider.translate('please_enter_valid_number');
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Date Field
              InkWell(
                onTap: _selectDate,
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: settingsProvider.translate('date'),
                    border: const OutlineInputBorder(),
                  ),
                  child: Text(
                    DateFormat.yMMMd().format(_selectedDate),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Category Selection
              Consumer<ExpenseProvider>(
                builder: (ctx, expenseProvider, child) {
                  final categories = expenseProvider.categories;
                  return DropdownButtonFormField<myapp.Category>(
                    decoration: InputDecoration(
                      labelText: settingsProvider.translate('category'),
                      border: const OutlineInputBorder(),
                    ),
                    value: _selectedCategory,
                    items: categories.map((category) {
                      return DropdownMenuItem(
                        value: category,
                        child: Row(
                          children: [
                            Icon(category.icon, color: category.color),
                            const SizedBox(width: 8),
                            Text(category.name),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                      });
                    },
                    validator: (value) {
                      if (value == null) {
                        return settingsProvider.translate('please_select_category');
                      }
                      return null;
                    },
                  );
                },
              ),
              const SizedBox(height: 24),

              // Submit Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  child: Text(
                    _isExpense
                        ? settingsProvider.translate('add_expense')
                        : settingsProvider.translate('add_income'),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
} 