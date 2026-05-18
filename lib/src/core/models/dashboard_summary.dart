class DashboardSummary {
  const DashboardSummary({
    required this.dailyTotal,
    required this.weeklyTotal,
    required this.monthlyTotal,
    required this.categoryBreakdown,
    required this.insights,
  });

  final double dailyTotal;
  final double weeklyTotal;
  final double monthlyTotal;
  final List<CategoryBreakdown> categoryBreakdown;
  final List<String> insights;

  factory DashboardSummary.fromJson(Map<String, dynamic> json) {
    final items = json['category_breakdown'] as List<dynamic>? ?? <dynamic>[];

    return DashboardSummary(
      dailyTotal: (json['daily_total'] as num).toDouble(),
      weeklyTotal: (json['weekly_total'] as num).toDouble(),
      monthlyTotal: (json['monthly_total'] as num).toDouble(),
      categoryBreakdown: items
          .map((item) => CategoryBreakdown.fromJson(item as Map<String, dynamic>))
          .toList(),
      insights: (json['insights'] as List<dynamic>? ?? <dynamic>[])
          .map((item) => item.toString())
          .toList(),
    );
  }
}

class CategoryBreakdown {
  const CategoryBreakdown({
    required this.category,
    required this.total,
  });

  final String category;
  final double total;

  factory CategoryBreakdown.fromJson(Map<String, dynamic> json) {
    return CategoryBreakdown(
      category: json['category'] as String,
      total: (json['total'] as num).toDouble(),
    );
  }
}
