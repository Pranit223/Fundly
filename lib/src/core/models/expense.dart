class Expense {
  const Expense({
    required this.id,
    required this.amount,
    required this.category,
    required this.note,
    required this.date,
  });

  final String id;
  final double amount;
  final String category;
  final String note;
  final DateTime date;

  factory Expense.fromJson(Map<String, dynamic> json) {
    return Expense(
      id: json['id'] as String,
      amount: (json['amount'] as num).toDouble(),
      category: json['category'] as String,
      note: json['note'] as String,
      date: DateTime.parse(json['date'] as String),
    );
  }
}
