import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';

/// Card AgroField - estilo Material 3, esquinas suaves, sin sombras duras.
class RuggedCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color backgroundColor;
  final double borderRadius;
  final bool border;

  const RuggedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(24.0),
    this.backgroundColor = AppColors.surfaceContainerLowest,
    this.borderRadius = 16.0,
    this.border = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: border
            ? Border.all(color: AppColors.outlineVariant, width: 1)
            : null,
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.04),
            offset: const Offset(0, 2),
            blurRadius: 12,
          ),
        ],
      ),
      child: child,
    );
  }
}
