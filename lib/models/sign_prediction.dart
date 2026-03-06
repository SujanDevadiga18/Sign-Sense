class SignPrediction {
  final String character;
  final double confidence;

  const SignPrediction({
    required this.character,
    required this.confidence,
  });

  factory SignPrediction.fromJson(Map<String, dynamic> json) {
    return SignPrediction(
      character: json['character'] as String? ?? '',
      confidence: (json['confidence'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

