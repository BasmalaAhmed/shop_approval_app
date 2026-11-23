import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/core/formatters.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_status_style.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/details_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/status_badge.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class DetailsCard extends StatelessWidget {
  const DetailsCard({
    super.key,
    required this.request,
    required this.operation,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'طلب رقم ${request.requestId}',
                style: AppStyles.categoryLabel,
              ),
              StatusBadge(
                approvalStatusStyle: ApprovalStatusStyle.resolve(
                  request,
                  operation,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(request.formattedAmount, style: AppStyles.amountLarge),
          const SizedBox(height: 16),
          const Divider(height: 1, thickness: 1, color: AppColors.divider),
          const SizedBox(height: 14),
          DetailsRow(label: 'الموظف', value: request.employeeName),
          DetailsRow(label: 'الفرع', value: request.branchName),
          DetailsRow(
            label: 'وقت الطلب',
            value: formatRequestTime(request.requestedAt),
          ),
          if (request.decidedAt != null)
            DetailsRow(
              label: 'وقت القرار',
              value: formatRequestTime(request.decidedAt!),
            ),
        ],
      ),
    );
  }
}
