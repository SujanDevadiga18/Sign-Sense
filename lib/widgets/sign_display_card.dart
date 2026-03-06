import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import 'neumorphic_card.dart';

class SignDisplayCard extends StatelessWidget {
  const SignDisplayCard({
    super.key,
    required this.title,
    required this.subtitle,
    this.signContent,
    this.primaryLabel,
    this.secondaryLabel,
    this.onPrimaryPressed,
    this.onSecondaryPressed,
  });

  final String title;
  final String subtitle;
  final Widget? signContent;
  final String? primaryLabel;
  final String? secondaryLabel;
  final VoidCallback? onPrimaryPressed;
  final VoidCallback? onSecondaryPressed;

  @override
  Widget build(BuildContext context) {
    return NeumorphicCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 160,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: signContent ??
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFFBFD2FF),
                          Color(0xFFECF2FF),
                        ],
                      ),
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.accessibility_new_rounded,
                        size: 72,
                        color: Colors.white,
                      ),
                    ),
                  ),
            ),
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              if (primaryLabel != null)
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onPrimaryPressed,
                    icon: const Icon(Icons.volume_up_rounded, size: 20),
                    label: Text(primaryLabel!),
                  ),
                ),
              if (primaryLabel != null && secondaryLabel != null)
                const SizedBox(width: 12),
              if (secondaryLabel != null)
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.accent,
                      side: const BorderSide(color: AppColors.accent, width: 1),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    onPressed: onSecondaryPressed,
                    icon: const Icon(Icons.bookmark_border_rounded, size: 20),
                    label: Text(secondaryLabel!),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

