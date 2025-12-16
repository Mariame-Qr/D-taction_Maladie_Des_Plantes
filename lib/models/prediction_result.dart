class PredictionResult {
  final String className;
  final double confidence;
  final String solution;
  final DateTime timestamp;

  PredictionResult({
    required this.className,
    required this.confidence,
    required this.solution,
    required this.timestamp,
  });

  factory PredictionResult.fromJson(Map<String, dynamic> json) {
    return PredictionResult(
      className: json['class'] ?? 'Unknown',
      confidence: (json['confidence'] ?? 0.0).toDouble(),
      solution: json['solution'] ?? 'Pas de solution disponible',
      timestamp: DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
    'class': className,
    'confidence': confidence,
    'solution': solution,
    'timestamp': timestamp.toIso8601String(),
  };

  String getConfidencePercentage() {
    return '${(confidence * 100).toStringAsFixed(2)}%';
  }
}
