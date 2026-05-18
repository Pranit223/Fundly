import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/expense_provider.dart';
import 'add_expense_screen.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  final _categoryController = TextEditingController();
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadExpensesOnly(
        token: context.read<AuthProvider>().token,
      );
    });
  }

  @override
  void dispose() {
    _categoryController.dispose();
    super.dispose();
  }

  Future<void> _pickStartDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _startDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _startDate = picked;
      });
      await _applyFilters();
    }
  }

  Future<void> _pickEndDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _endDate ?? DateTime.now(),
    );

    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
      await _applyFilters();
    }
  }

  Future<void> _applyFilters() async {
    await context.read<ExpenseProvider>().loadExpensesOnly(
      token: context.read<AuthProvider>().token,
      category: _categoryController.text.trim(),
      startDate: _startDate,
      endDate: _endDate,
    );
  }

  Future<void> _clearFilters() async {
    setState(() {
      _categoryController.clear();
      _startDate = null;
      _endDate = null;
    });
    await _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rs ');

    return AppScaffold(
      title: 'Expenses',
      currentIndex: 1,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.expenses.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }

          return RefreshIndicator(
            onRefresh: _applyFilters,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        TextField(
                          controller: _categoryController,
                          decoration: InputDecoration(
                            labelText: 'Filter by category',
                            suffixIcon: IconButton(
                              onPressed: _applyFilters,
                              icon: const Icon(Icons.search),
                            ),
                          ),
                          onSubmitted: (_) => _applyFilters(),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _pickStartDate,
                                child: Text(
                                  _startDate == null
                                      ? 'Start date'
                                      : DateFormat('dd MMM yyyy').format(_startDate!),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: _pickEndDate,
                                child: Text(
                                  _endDate == null
                                      ? 'End date'
                                      : DateFormat('dd MMM yyyy').format(_endDate!),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: _clearFilters,
                            child: const Text('Clear filters'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (provider.expenses.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No expenses found for the selected filters.'),
                    ),
                  )
                else
                  ...provider.expenses.map((expense) {
                    return Card(
                      child: ListTile(
                        title: Text(expense.note),
                        subtitle: Text(
                          '${expense.category} • ${DateFormat('dd MMM yyyy').format(expense.date)}',
                        ),
                        trailing: Wrap(
                          spacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(currency.format(expense.amount)),
                            IconButton(
                              onPressed: () async {
                                await Navigator.of(context).push(
                                  MaterialPageRoute<void>(
                                    builder: (_) => AddExpenseScreen(expense: expense),
                                  ),
                                );
                                await _applyFilters();
                              },
                              icon: const Icon(Icons.edit_outlined),
                            ),
                            IconButton(
                              onPressed: () async {
                                await provider.deleteExpense(expense.id);
                                await _applyFilters();
                              },
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
              ],
            ),
          );
        },
      ),
    );
  }
}
