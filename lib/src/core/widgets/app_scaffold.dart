import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../features/auth/providers/auth_provider.dart';
import '../../features/dashboard/screens/dashboard_screen.dart';
import '../../features/expenses/providers/expense_provider.dart';
import '../../features/expenses/screens/add_expense_screen.dart';
import '../../features/expenses/screens/expense_list_screen.dart';

class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.title,
    required this.body,
    this.currentIndex = 0,
  });

  final String title;
  final Widget body;
  final int currentIndex;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            onPressed: () async {
              await context.read<AuthProvider>().logout();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: body,
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => const AddExpenseScreen(),
            ),
          );
          await context.read<ExpenseProvider>().loadAllData(
            token: context.read<AuthProvider>().token,
          );
        },
        icon: const Icon(Icons.add),
        label: const Text('Expense'),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: currentIndex,
        onDestinationSelected: (index) {
          if (index == currentIndex) {
            return;
          }

          final destination = switch (index) {
            0 => const DashboardScreen(),
            1 => const ExpenseListScreen(),
            _ => const DashboardScreen(),
          };

          Navigator.of(context).pushReplacement(
            MaterialPageRoute<void>(builder: (_) => destination),
          );
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.receipt_long_outlined),
            selectedIcon: Icon(Icons.receipt_long),
            label: 'Expenses',
          ),
        ],
      ),
    );
  }
}
