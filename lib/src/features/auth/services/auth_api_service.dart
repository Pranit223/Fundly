import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/config/app_config.dart';
import '../../../core/models/auth_session.dart';

class AuthApiService {
  AuthApiService({http.Client? client}) : _client = client ?? http.Client();

  final http.Client _client;

  Future<AuthSession> signup({
    required String email,
    required String password,
    double? monthlyBudget,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/signup'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'monthly_budget': monthlyBudget,
      }),
    );

    return _parseSession(response, fallbackMessage: 'Signup failed.');
  }

  Future<AuthSession> login({
    required String email,
    required String password,
  }) async {
    final response = await _client.post(
      Uri.parse('${AppConfig.baseUrl}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    return _parseSession(response, fallbackMessage: 'Login failed.');
  }

  AuthSession _parseSession(
    http.Response response, {
    required String fallbackMessage,
  }) {
    final decoded = jsonDecode(response.body) as Map<String, dynamic>;

    if (response.statusCode >= 400) {
      throw decoded['detail']?.toString() ?? fallbackMessage;
    }

    return AuthSession.fromJson(decoded);
  }
}
