import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';

class OutlineButton extends StatelessWidget {
  const OutlineButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.borderColor = AppColors.warningText,
    this.textColor = AppColors.warningText,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final Color borderColor;
  final Color textColor;

  factory OutlineButton.reject({required VoidCallback? onPressed}) {
    return OutlineButton(
      label: 'رفض',
      icon: Icons.close_rounded,
      onPressed: onPressed,
    );
  }

  factory OutlineButton.neutral({
    required String label,
    required VoidCallback? onPressed,
    IconData? icon,
  }) {
    return OutlineButton(
      label: label,
      icon: icon,
      borderColor: AppColors.offlineGreyBorder,
      textColor: AppColors.primaryTeal,
      onPressed: onPressed,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = onPressed != null;
    final contentColor = isEnabled ? textColor : AppColors.textMuted;
    return SizedBox(
      height: 48,
      child: Material(
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isEnabled ? borderColor : AppColors.cardBorder,
            width: 1.2,
          ),
        ),
        child: InkWell(
          onTap: onPressed,
          borderRadius: BorderRadius.circular(12),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (icon != null) ...[
                  Icon(icon, size: 18, color: contentColor),
                  const SizedBox(width: 8),
                ],
                Text(
                  label,
                  style: AppStyles.buttonText.copyWith(color: contentColor),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
