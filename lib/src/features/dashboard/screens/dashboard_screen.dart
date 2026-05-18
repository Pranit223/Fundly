import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../core/widgets/app_scaffold.dart';
import '../../auth/providers/auth_provider.dart';
import '../../expenses/providers/expense_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ExpenseProvider>().loadAllData(
        token: context.read<AuthProvider>().token,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final currency = NumberFormat.currency(symbol: 'Rs ');

    return AppScaffold(
      title: 'Dashboard',
      currentIndex: 0,
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.dashboard == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.errorMessage != null && provider.dashboard == null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final dashboard = provider.dashboard;
          final alerts = provider.alerts;
          final recentExpenses = provider.expenses.take(5).toList();

          if (dashboard == null) {
            return const Center(child: Text('No dashboard data available.'));
          }

          return RefreshIndicator(
            onRefresh: () => provider.loadAllData(
              token: context.read<AuthProvider>().token,
            ),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
              children: [
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    _SummaryCard(
                      title: 'Today',
                      amount: currency.format(dashboard.dailyTotal),
                    ),
                    _SummaryCard(
                      title: 'This Week',
                      amount: currency.format(dashboard.weeklyTotal),
                    ),
                    _SummaryCard(
                      title: 'This Month',
                      amount: currency.format(dashboard.monthlyTotal),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Category breakdown',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (dashboard.categoryBreakdown.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No expenses added yet.'),
                    ),
                  )
                else
                  ...dashboard.categoryBreakdown.map(
                    (item) => Card(
                      child: ListTile(
                        title: Text(item.category),
                        trailing: Text(currency.format(item.total)),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'AI insights',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (dashboard.insights.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Add a few expenses to unlock smart insights.'),
                    ),
                  )
                else
                  ...dashboard.insights.map(
                    (insight) => Card(
                      color: const Color(0xFFECFEFF),
                      child: ListTile(
                        leading: const Icon(Icons.auto_awesome),
                        title: Text(insight),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Alerts',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                if (alerts.isEmpty)
                  const Card(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('No alerts right now.'),
                    ),
                  )
                else
                  ...alerts.map(
                    (alert) => Card(
                      color: alert.type == 'budget'
                          ? const Color(0xFFFFF7ED)
                          : const Color(0xFFFEE2E2),
                      child: ListTile(
                        leading: Icon(
                          alert.type == 'budget'
                              ? Icons.warning_amber_rounded
                              : Icons.priority_high_rounded,
                        ),
                        title: Text(alert.message),
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Text(
                  'Recent expenses',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...recentExpenses.map(
                  (expense) => Card(
                    child: ListTile(
                      title: Text(expense.note),
                      subtitle: Text(expense.category),
                      trailing: Text(currency.format(expense.amount)),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
  });

  final String title;
  final String amount;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              Text(
                amount,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
