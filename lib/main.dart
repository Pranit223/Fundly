import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'src/app.dart';
import 'src/core/services/token_storage.dart';
import 'src/features/auth/providers/auth_provider.dart';
import 'src/features/expenses/providers/expense_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final authProvider = AuthProvider(tokenStorage: tokenStorage);
  await authProvider.restoreSession();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
        ChangeNotifierProxyProvider<AuthProvider, ExpenseProvider>(
          create: (_) => ExpenseProvider(),
          update: (_, authProvider, expenseProvider) {
            final provider = expenseProvider ?? ExpenseProvider();
            provider.updateSession(token: authProvider.token);
            return provider;
          },
        ),
      ],
      child: const ExpenseTrackerApp(),
    ),
  );
}
