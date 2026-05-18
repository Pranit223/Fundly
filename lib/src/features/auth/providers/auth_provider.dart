import 'package:flutter/foundation.dart';

import '../../../core/models/auth_session.dart';
import '../../../core/services/token_storage.dart';
import '../services/auth_api_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider({required TokenStorage tokenStorage})
    : _tokenStorage = tokenStorage,
      _authApiService = AuthApiService();

  final TokenStorage _tokenStorage;
  final AuthApiService _authApiService;

  String? _token;
  String? _email;
  bool _isLoading = true;

  String? get token => _token;
  String? get email => _email;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null && _token!.isNotEmpty;

  Future<void> restoreSession() async {
    _isLoading = true;
    notifyListeners();

    final (token, email) = await _tokenStorage.read();
    _token = token;
    _email = email;
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final session = await _authApiService.login(email: email, password: password);
    await _persistSession(session);
  }

  Future<void> signup({
    required String email,
    required String password,
    double? monthlyBudget,
  }) async {
    final session = await _authApiService.signup(
      email: email,
      password: password,
      monthlyBudget: monthlyBudget,
    );
    await _persistSession(session);
  }

  Future<void> logout() async {
    _token = null;
    _email = null;
    await _tokenStorage.clear();
    notifyListeners();
  }

  Future<void> _persistSession(AuthSession session) async {
    _token = session.accessToken;
    _email = session.email;
    await _tokenStorage.save(token: session.accessToken, email: session.email);
    notifyListeners();
  }
}
