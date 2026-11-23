import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_status_style.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/status_badge.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/warning_banner.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({
    super.key,
    required this.request,
    required this.operation,
    required this.onTap,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;
  final VoidCallback onTap;

  String? get _completedNote {
    if (request.status == ApprovalStatus.approved &&
        request.executedAsEmployee != null) {
      return 'نُفّذت باسم ${request.executedAsEmployee}';
    }
    if (request.wasRejected) {
      return 'عادت مسودة عند ${request.employeeName}';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final highlightAttention = request.hasAttention && request.isPending;
    final attentionMessage = request.attentionMessage;
    final completedNote = _completedNote;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: highlightAttention
              ? AppColors.warningBorderStrong
              : AppColors.cardBorder,
          width: highlightAttention ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        request.reason,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppStyles.categoryLabel,
                      ),
                    ),
                    const SizedBox(width: 8),
                    StatusBadge(
                      approvalStatusStyle: ApprovalStatusStyle.resolve(
                        request,
                        operation,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(request.formattedAmount, style: AppStyles.amountMedium),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(
                      Icons.person_outline_rounded,
                      size: 16,
                      color: AppColors.textMuted,
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Wrap(
                        spacing: 6,
                        children: [
                          Text(
                            request.employeeName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          const Text(
                            '·',
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                          Text(
                            request.branchName,
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textSecondary,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (request.hasAttention && attentionMessage != null) ...[
                  const SizedBox(height: 12),
                  WarningBanner(compact: true, title: attentionMessage),
                ],
                if (completedNote != null) ...[
                  const SizedBox(height: 8),
                  Text(
                    completedNote,
                    style: const TextStyle(
                      fontSize: 11,
                      color: AppColors.textMuted,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
