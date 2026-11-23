import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/warning_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/custom_button.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ConfirmSheet extends StatefulWidget {
  const ConfirmSheet({
    super.key,
    required this.request,
    required this.onConfirm,
  });

  final ApprovalRequest request;
  final VoidCallback onConfirm;

  static Future<void> show({
    required BuildContext context,
    required ApprovalRequest request,
    required VoidCallback onConfirm,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => ConfirmSheet(request: request, onConfirm: onConfirm),
    );
  }

  @override
  State<ConfirmSheet> createState() => _ConfirmSheetState();
}

class _ConfirmSheetState extends State<ConfirmSheet> {
  bool _reviewedWarning = false;
  @override
  Widget build(BuildContext context) {
    final attention = widget.request.attentionMessage ?? '';

    return Container(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        top: 12,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 44,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFE2E8F0),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'الموافقة على ${widget.request.formattedAmount}؟',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          WarningBanner(
            title: attention,
            subtitle: 'تأكد من مراجعة التنبيه قبل الموافقة.',
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () => setState(() => _reviewedWarning = !_reviewedWarning),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Checkbox(
                  value: _reviewedWarning,
                  activeColor: AppColors.primaryTeal,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                  onChanged: (value) =>
                      setState(() => _reviewedWarning = value ?? false),
                ),
                const Text(
                  'راجعتُ التنبيه',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          CustomButton(
            label: 'تأكيد الموافقة',
            icon: Icons.check_rounded,
            bgColor: _reviewedWarning
                ? AppColors.primaryTeal
                : Color(0XFF8C95A3),
            onTap: _reviewedWarning
                ? () {
                    Navigator.pop(context);
                    widget.onConfirm();
                  }
                : null,
          ),
          const SizedBox(height: 10),
          Center(
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'إلغاء',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primaryTeal,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
