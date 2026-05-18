class AlertItem {
  const AlertItem({
    required this.type,
    required this.message,
  });

  final String type;
  final String message;

  factory AlertItem.fromJson(Map<String, dynamic> json) {
    return AlertItem(
      type: json['type'] as String,
      message: json['message'] as String,
    );
  }
}
