import 'package:flutter/foundation.dart';

import '../../../core/models/alert_item.dart';
import '../../../core/models/ai_category_suggestion.dart';
import '../../../core/models/dashboard_summary.dart';
import '../../../core/models/expense.dart';
import '../services/expense_api_service.dart';

class ExpenseProvider extends ChangeNotifier {
  ExpenseProvider() : _expenseApiService = ExpenseApiService();

  final ExpenseApiService _expenseApiService;

  String? _token;
  bool _isLoading = false;
  String? _errorMessage;
  List<Expense> _expenses = [];
  DashboardSummary? _dashboard;
  List<AlertItem> _alerts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Expense> get expenses => _expenses;
  DashboardSummary? get dashboard => _dashboard;
  List<AlertItem> get alerts => _alerts;

  void updateSession({String? token}) {
    _token = token;
    if (token == null) {
      _expenses = [];
      _dashboard = null;
      _alerts = [];
      _errorMessage = null;
      notifyListeners();
    }
  }

  Future<void> loadAllData({String? token}) async {
    final authToken = token ?? _token;
    if (authToken == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final expenses = await _expenseApiService.fetchExpenses(token: authToken);
      final dashboard = await _expenseApiService.fetchDashboard(token: authToken);
      final alerts = await _expenseApiService.fetchAlerts(token: authToken);

      _expenses = expenses;
      _dashboard = dashboard;
      _alerts = alerts;
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadExpensesOnly({
    String? token,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final authToken = token ?? _token;
    if (authToken == null) {
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _expenses = await _expenseApiService.fetchExpenses(
        token: authToken,
        category: category,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> saveExpense({
    String? id,
    required double amount,
    required String note,
    required DateTime date,
    String? category,
  }) async {
    if (_token == null) {
      throw 'Please login again.';
    }

    if (id == null) {
      await _expenseApiService.createExpense(
        token: _token!,
        amount: amount,
        note: note,
        date: date,
        category: category,
      );
    } else {
      await _expenseApiService.updateExpense(
        token: _token!,
        id: id,
        amount: amount,
        note: note,
        date: date,
        category: category,
      );
    }

    await loadAllData();
  }

  Future<void> deleteExpense(String id) async {
    if (_token == null) {
      throw 'Please login again.';
    }

    await _expenseApiService.deleteExpense(token: _token!, id: id);
    await loadAllData();
  }

  Future<AICategorySuggestion> fetchCategorySuggestion(String note) async {
    if (_token == null) {
      throw 'Please login again.';
    }

    return _expenseApiService.fetchCategorySuggestion(
      token: _token!,
      note: note,
    );
  }
}
