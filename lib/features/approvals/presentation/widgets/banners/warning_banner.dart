import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';

class WarningBanner extends StatelessWidget {
  const WarningBanner({
    super.key,
    required this.title,
    this.subtitle,
    this.compact = false,
  });

  final String title;
  final String? subtitle;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final subtitleText = subtitle;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(
        horizontal: 14,
        vertical: compact ? 10 : 12,
      ),
      decoration: BoxDecoration(
        color: AppColors.warningBg,
        borderRadius: BorderRadius.circular(12),
        border: compact
            ? null
            : Border.all(
                color: AppColors.warningBorderStrong.withValues(alpha: 0.4),
                width: 1.2,
              ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(
                Icons.warning_amber_rounded,
                size: compact ? 18 : 20,
                color: AppColors.warningText,
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: AppStyles.bannerTitle.copyWith(
                    color: AppColors.warningText,
                    fontSize: compact ? 12.5 : null,
                  ),
                ),
              ),
            ],
          ),
          if (!compact && subtitleText != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitleText,
              textAlign: TextAlign.center,
              style: AppStyles.bannerSubtitle.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
