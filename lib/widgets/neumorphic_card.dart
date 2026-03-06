import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';

class NeumorphicCard extends StatelessWidget {
  const NeumorphicCard({
    super.key,
    this.child,
    this.padding = const EdgeInsets.all(20),
    this.margin,
    this.onTap,
  });

  final Widget? child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry? margin;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final card = AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      curve: Curves.easeOut,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : AppColors.background,
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [const Color(0xFF2C2C2C), const Color(0xFF1A1A1A)]
              : [const Color(0xFFF5F7FF), const Color(0xFFE3ECFF)],
        ),
        boxShadow: [
          BoxShadow(
            color: isDark ? AppColors.shadowDarkDarkTheme : AppColors.shadowDark,
            offset: const Offset(8, 8),
            blurRadius: 18,
            spreadRadius: 1,
          ),
          BoxShadow(
            color: isDark ? AppColors.shadowLightDarkTheme : AppColors.shadowLight,
            offset: const Offset(-8, -8),
            blurRadius: 18,
            spreadRadius: 1,
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return card;

    return GestureDetector(
      onTap: onTap,
      child: card,
    );
  }
}

