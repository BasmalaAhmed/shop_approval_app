import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalStatusStyle {
  const ApprovalStatusStyle({
    required this.label,
    required this.background,
    required this.foreground,
    this.icon,
  });

  final String label;
  final Color background;
  final Color foreground;

  final IconData? icon;

  static const _pending = ApprovalStatusStyle(
    label: 'قيد المراجعة',
    background: AppColors.pendingBg,
    foreground: AppColors.pendingText,
    icon: Icons.circle,
  );

  static const _needsAttention = ApprovalStatusStyle(
    label: 'يحتاج انتباه',
    background: AppColors.warningBg,
    foreground: AppColors.warningText,
    icon: Icons.warning_amber_rounded,
  );

  static const _submitting = ApprovalStatusStyle(
    label: 'جارِ الإرسال',
    background: AppColors.pendingBg,
    foreground: AppColors.pendingText,
    icon: Icons.sync_rounded,
  );

  static const _unconfirmed = ApprovalStatusStyle(
    label: 'غير مؤكد بعد',
    background: AppColors.syncWarningBg,
    foreground: AppColors.syncWarningText,
    icon: Icons.access_time_rounded,
  );

  static const _approved = ApprovalStatusStyle(
    label: 'تمت الموافقة',
    background: AppColors.approvedBg,
    foreground: AppColors.approvedText,
    icon: Icons.check_rounded,
  );

  static const _rejected = ApprovalStatusStyle(
    label: 'مرفوض',
    background: AppColors.rejectedBg,
    foreground: AppColors.rejectedText,
    icon: Icons.close_rounded,
  );

  factory ApprovalStatusStyle.resolve(
    ApprovalRequest request,
    DecisionOperationState operation,
  ) {
    if (operation is DecisionSubmitting) {
      return _submitting;
    }
    if (operation is DecisionCheckingOutcome ||
        operation is DecisionUnknownOutcome) {
      return _unconfirmed;
    }

    switch (request.status) {
      case ApprovalStatus.pending:
        return request.hasAttention ? _needsAttention : _pending;
      case ApprovalStatus.approved:
        return _approved;
      case ApprovalStatus.rejected:
        return _rejected;
    }
  }
}
