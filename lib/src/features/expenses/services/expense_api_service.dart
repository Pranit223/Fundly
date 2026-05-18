import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/models/alert_item.dart';
import '../../../core/models/ai_category_suggestion.dart';
import '../../../core/models/dashboard_summary.dart';
import '../../../core/models/expense.dart';

class ExpenseApiService {
  ExpenseApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<List<Expense>> fetchExpenses({
    required String token,
    String? category,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final queryParameters = <String, String>{};
    if (category != null && category.trim().isNotEmpty) {
      queryParameters['category'] = category.trim();
    }
    if (startDate != null) {
      queryParameters['start_date'] = startDate.toIso8601String();
    }
    if (endDate != null) {
      queryParameters['end_date'] = endDate.toIso8601String();
    }

    final response = await _client.get(
      Uri.parse(
        '${AppConfig.baseUrl}/expenses',
      ).replace(queryParameters: queryParameters.isEmpty ? null : queryParameters),
      headers: _headers(token),
    );

    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => Expense.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<DashboardSummary> fetchDashboard({required String token}) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.baseUrl}/dashboard'),
      headers: _headers(token),
    );

    return DashboardSummary.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  Future<List<AlertItem>> fetchAlerts({required String token}) async {
    final response = await _client.get(
      Uri.parse('${AppConfig.baseUrl}/alerts'),
      headers: _headers(token),
    );

    final decoded = _decode(response) as List<dynamic>;
    return decoded
        .map((item) => AlertItem.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<AICategorySuggestion> fetchCategorySuggestion({
    required String token,
    required String note,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/ai/category-suggestion'),
      headers: _headers(token),
      body: jsonEncode({'note': note}),
    );

    return AICategorySuggestion.fromJson(
      _decode(response) as Map<String, dynamic>,
    );
  }

  Future<void> createExpense({
    required String token,
    required double amount,
    required String note,
    required DateTime date,
    String? category,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/expense'),
      headers: _headers(token),
      body: jsonEncode({
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
        'category': category,
      }),
    );

    _decode(response);
  }

  Future<void> updateExpense({
    required String token,
    required String id,
    required double amount,
    required String note,
    required DateTime date,
    String? category,
  }) async {
    final response = await _client.put(
      Uri.parse('${AppConfig.baseUrl}/expense/$id'),
      headers: _headers(token),
      body: jsonEncode({
        'amount': amount,
        'note': note,
        'date': date.toIso8601String(),
        'category': category,
      }),
    );

    _decode(response);
  }

  Future<void> deleteExpense({
    required String token,
    required String id,
  }) async {
    final response = await _client.delete(
      Uri.parse('${AppConfig.baseUrl}/expense/$id'),
      headers: _headers(token),
    );

    if (response.statusCode >= 400) {
      _decode(response);
    }
  }

  Map<String, String> _headers(String token) {
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  dynamic _decode(http.Response response) {
    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);

    if (response.statusCode >= 400) {
      if (decoded is Map<String, dynamic> && decoded['detail'] != null) {
        throw decoded['detail'].toString();
      }
      throw 'Request failed with status ${response.statusCode}.';
    }

    return decoded;
  }
}
