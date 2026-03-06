import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../models/conversation_entry.dart';
import 'neumorphic_card.dart';

class ConversationBubble extends StatelessWidget {
  const ConversationBubble({
    super.key,
    required this.entry,
  });

  final ConversationEntry entry;

  @override
  Widget build(BuildContext context) {
    final subtitle = <String>[
      if (entry.fromVoice) 'Voice input',
      if (entry.fromCamera) 'Camera detection',
    ].join(' • ');

    return NeumorphicCard(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                colors: [
                  AppColors.primaryBlue,
                  AppColors.secondaryBlue,
                ],
              ),
            ),
            child: const Icon(
              Icons.accessibility_new_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.sourceText,
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                if (entry.detectedSign != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Detected: ${entry.detectedSign}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
                const SizedBox(height: 4),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      subtitle.isEmpty ? 'Text input' : subtitle,
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    Text(
                      _formatTime(entry.timestamp),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                            color: AppColors.textSecondary.withOpacity(0.9),
                          ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime timestamp) {
    final hour = timestamp.hour.toString().padLeft(2, '0');
    final minute = timestamp.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

