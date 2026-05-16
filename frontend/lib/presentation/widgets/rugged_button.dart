import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text.dart';

/// Botón principal AgroField - píldora Material 3.
class RuggedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final Color backgroundColor;
  final Color? textColor;
  final bool isOutlined;
  final IconData? icon;
  final double height;

  const RuggedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.backgroundColor = AppColors.primary,
    this.textColor,
    this.isOutlined = false,
    this.icon,
    this.height = 56,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isOutlined ? Colors.transparent : backgroundColor;
    final fg =
        textColor ?? (isOutlined ? AppColors.primary : AppColors.onPrimary);

    return SizedBox(
      width: double.infinity,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: bg,
          foregroundColor: fg,
          elevation: isOutlined ? 0 : 2,
          shadowColor: AppColors.primary.withValues(alpha: 0.2),
          shape: StadiumBorder(
            side: isOutlined
                ? BorderSide(color: fg, width: 1.5)
                : BorderSide.none,
          ),
          padding: EdgeInsets.zero,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) ...[
              Icon(icon, color: fg, size: 20),
              const SizedBox(width: 8),
            ],
            Text(text.toUpperCase(), style: AppText.labelCapsLg(color: fg)),
          ],
        ),
      ),
    );
  }
}
