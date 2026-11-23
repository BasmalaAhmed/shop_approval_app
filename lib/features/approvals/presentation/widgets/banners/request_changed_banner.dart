import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/core/formatters.dart';
import 'package:shop_approval_app/models/request_change.dart';

class RequestChangedBanner extends StatelessWidget {
  const RequestChangedBanner({super.key, required this.change});

  final RequestChange change;

  @override
  Widget build(BuildContext context) {
    const accent = AppColors.updatedNoticeText;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.updatedNoticeBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.updatedNoticeBorder, width: 1.2),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.sync_rounded, size: 20, color: accent),
          const SizedBox(width: 10,),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'الطلب تغيّر أثناء عرضه',
                style: AppStyles.bannerTitle.copyWith(color: accent),
              ),
              const SizedBox(height: 6),
              Text(
                'تم تعديل البيانات. راجع البيانات الجديدة قبل القرار.',
                style: AppStyles.bannerSubtitle.copyWith(color: AppColors.textSecondary),
              ),
              for (final line in _diffLines()) ...[const SizedBox(height: 6), line],
            ],
          ),
        ],
      ),
    );
  }

  List<Widget> _diffLines() {
    String money(int piastres) => formatPiastres(piastres, currency: '').trim();

    final lines = <Widget>[
      if (change.amountChanged)
        _diffLine(
          'المبلغ',
          money(change.previous.amountInPiastres),
          money(change.latest.amountInPiastres),
        ),
      if (change.branchChanged)
        _diffLine('الفرع', change.previous.branchName, change.latest.branchName),
      if (change.employeeChanged)
        _diffLine('الموظف', change.previous.employeeName, change.latest.employeeName),
      if (change.reasonChanged) _noteLine('تم تعديل سبب الطلب'),
      if (change.attentionChanged) _noteLine('تغيّر تنبيه الطلب'),
    ];

    return lines.isEmpty ? [_noteLine('تغيّرت بيانات الطلب.')] : lines;
  }

  Widget _diffLine(String label, String before, String after) {
    return Text.rich(
      TextSpan(
        style: AppStyles.bannerSubtitle.copyWith(color: AppColors.textSecondary),
        children: [
          TextSpan(text: '$label: '),
          TextSpan(
            text: before,
            style: const TextStyle(decoration: TextDecoration.lineThrough),
          ),
          const TextSpan(text: ' ← '),
          TextSpan(
            text: after,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppColors.updatedNoticeText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noteLine(String text) => Text(
    text,
    style: AppStyles.bannerSubtitle.copyWith(color: AppColors.textSecondary),
  );
}