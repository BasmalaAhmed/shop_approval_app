import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/formatters.dart';

class TintedBanner extends StatelessWidget {
  const TintedBanner({
    super.key,
    required this.background,
    required this.border,
    required this.accent,
    required this.icon,
    required this.title,
    required this.message,
    this.footer,
  });

  final Color background;
  final Color border;
  final Color accent;
  final IconData icon;
  final String title;
  final String message;
  final String? footer;

  @override
  Widget build(BuildContext context) {
    final footerText = footer;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: border, width: 1.2),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 20, color: accent),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  title,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w400,
              color: AppColors.textSecondary,
              height: 1.4,
            ),
          ),
          if (footerText != null) ...[
            const SizedBox(height: 6),
            Text(
              footerText,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: AppColors.textMuted,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class UnconfirmedOutcomeBanner extends StatelessWidget {
  const UnconfirmedOutcomeBanner({
    super.key,
    required this.title,
    required this.message,
    required this.decisionId,
  });

  final String title;
  final String message;
  final String decisionId;

  @override
  Widget build(BuildContext context) {
    return TintedBanner(
      background: AppColors.syncWarningBg,
      border: AppColors.syncWarningBorder,
      accent: AppColors.syncWarningText,
      icon: Icons.sync_rounded,
      title: title,
      message: message,
      footer: 'رقم القرار ${shortDecisionId(decisionId)}',
    );
  }
}

class RequestUpdatedBanner extends StatelessWidget {
  const RequestUpdatedBanner({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return TintedBanner(
      background: AppColors.updatedNoticeBg,
      border: AppColors.updatedNoticeBorder,
      accent: AppColors.updatedNoticeText,
      icon: Icons.sync_rounded,
      title: 'الطلب تغيّر أثناء عرضه',
      message: message,
      footer: 'عدّل أحمد محمود المبلغ. راجع البيانات الجديدة قبل القرار.',
    );
  }
}
