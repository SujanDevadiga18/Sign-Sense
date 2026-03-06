class ConversationEntry {
  final String id;
  final String sourceText;
  final String? detectedSign;
  final bool fromVoice;
  final bool fromCamera;
  final DateTime timestamp;

  ConversationEntry({
    required this.id,
    required this.sourceText,
    this.detectedSign,
    this.fromVoice = false,
    this.fromCamera = false,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

