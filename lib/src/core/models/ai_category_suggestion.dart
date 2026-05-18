class AICategorySuggestion {
  const AICategorySuggestion({
    required this.category,
    required this.reason,
    required this.confidence,
    required this.source,
  });

  final String category;
  final String reason;
  final double confidence;
  final String source;

  String get confidenceLabel => '${(confidence * 100).round()}% confidence';
  bool get isAiPowered => source == 'ollama';

  factory AICategorySuggestion.fromJson(Map<String, dynamic> json) {
    return AICategorySuggestion(
      category: json['category'] as String,
      reason: json['reason'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      source: json['source'] as String,
    );
  }
}
