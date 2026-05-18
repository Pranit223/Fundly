import 'dart:async';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/models/ai_category_suggestion.dart';
import '../../../core/models/expense.dart';
import '../providers/expense_provider.dart';

class AddExpenseScreen extends StatefulWidget {
  const AddExpenseScreen({super.key, this.expense});

  final Expense? expense;

  @override
  State<AddExpenseScreen> createState() => _AddExpenseScreenState();
}

class _AddExpenseScreenState extends State<AddExpenseScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _amountController;
  late final TextEditingController _categoryController;
  late final TextEditingController _noteController;
  late DateTime _selectedDate;
  Timer? _debounce;
  AICategorySuggestion? _suggestion;
  int _suggestionRequestId = 0;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final expense = widget.expense;
    _amountController = TextEditingController(
      text: expense?.amount.toStringAsFixed(0) ?? '',
    );
    _categoryController = TextEditingController(text: expense?.category ?? '');
    _noteController = TextEditingController(text: expense?.note ?? '');
    _selectedDate = expense?.date ?? DateTime.now();
    _noteController.addListener(_handleNoteChanged);
    if (_noteController.text.trim().length >= 2 && expense == null) {
      _requestSuggestion(_noteController.text.trim());
    }
  }

  @override
  void dispose() {
    _noteController.removeListener(_handleNoteChanged);
    _debounce?.cancel();
    _amountController.dispose();
    _categoryController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  void _handleNoteChanged() {
    final note = _noteController.text.trim();
    _debounce?.cancel();

    if (note.length < 2) {
      setState(() {
        _suggestion = null;
      });
      return;
    }

    _debounce = Timer(const Duration(milliseconds: 450), () {
      _requestSuggestion(note);
    });
  }

  Future<void> _requestSuggestion(String note) async {
    final requestId = ++_suggestionRequestId;
    try {
      final suggestion = await context.read<ExpenseProvider>().fetchCategorySuggestion(
        note,
      );
      if (!mounted || requestId != _suggestionRequestId) {
        return;
      }
      setState(() {
        _suggestion = suggestion;
      });
    } catch (_) {
      if (!mounted || requestId != _suggestionRequestId) {
        return;
      }
      setState(() {
        _suggestion = null;
      });
    }
  }

  void _applySuggestion() {
    if (_suggestion == null) {
      return;
    }
    setState(() {
      _categoryController.text = _suggestion!.category;
    });
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
      initialDate: _selectedDate,
    );

    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _saving = true;
    });

    try {
      await context.read<ExpenseProvider>().saveExpense(
        id: widget.expense?.id,
        amount: double.parse(_amountController.text.trim()),
        note: _noteController.text.trim(),
        date: _selectedDate,
        category: _categoryController.text.trim().isEmpty
            ? null
            : _categoryController.text.trim(),
      );

      if (!mounted) {
        return;
      }

      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    } finally {
      if (mounted) {
        setState(() {
          _saving = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat('dd MMM yyyy').format(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.expense == null ? 'Add expense' : 'Edit expense'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _amountController,
                decoration: const InputDecoration(labelText: 'Amount'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  final parsed = double.tryParse(value?.trim() ?? '');
                  if (parsed == null || parsed <= 0) {
                    return 'Enter a valid amount';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(
                  labelText: 'Category (optional for AI auto-categorization)',
                ),
              ),
              const SizedBox(height: 12),
              if (_suggestion != null)
                Card(
                  color: const Color(0xFFE6FFFB),
                  child: ListTile(
                    leading: Icon(
                      _suggestion!.isAiPowered
                          ? Icons.psychology
                          : Icons.tips_and_updates,
                    ),
                    title: Text('Suggested category: ${_suggestion!.category}'),
                    subtitle: Text(
                      '${_suggestion!.reason} - ${_suggestion!.confidenceLabel}'
                      '${_suggestion!.isAiPowered ? ' - AI' : ' - Fallback'}',
                    ),
                    trailing: TextButton(
                      onPressed: _applySuggestion,
                      child: const Text('Use'),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(labelText: 'Note'),
                maxLines: 3,
                validator: (value) {
                  if ((value ?? '').trim().length < 2) {
                    return 'Enter a meaningful note';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              Card(
                child: ListTile(
                  title: const Text('Expense date'),
                  subtitle: Text(dateLabel),
                  trailing: const Icon(Icons.calendar_month),
                  onTap: _pickDate,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton(
                onPressed: _saving ? null : _save,
                child: Text(_saving ? 'Saving...' : 'Save expense'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
