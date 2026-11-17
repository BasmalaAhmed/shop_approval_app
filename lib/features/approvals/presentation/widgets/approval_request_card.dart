import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_status_chip.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({
    super.key,
    required this.request,
    required this.operation,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;

  @override
  Widget build(BuildContext context) {
    final pounds = request.amountInPiastres ~/ 100;
    final piastres = request.amountInPiastres % 100;

    String? operationMessage;
    Color? operationColor;

    if (operation is DecisionSubmitting) {
      operationMessage = 'جارٍ إرسال القرار...';
      operationColor = Colors.blue;
    } else if (operation is DecisionCheckingOutcome) {
      operationMessage = 'جارٍ التحقق من النتيجة...';
      operationColor = Colors.blue;
    } else if (operation is DecisionUnknownOutcome) {
      final unknown = operation as DecisionUnknownOutcome;
      operationMessage = unknown.message ?? 'نتيجة القرار غير مؤكدة';
      operationColor = Colors.orange;
    } else if (operation is DecisionConflict) {
      operationMessage = 'تم تحديث الطلب من جهاز آخر';
      operationColor = Colors.orange;
    } else if (operation is DecisionFailure) {
      final failure = operation as DecisionFailure;
      operationMessage = failure.message;
      operationColor = Colors.red;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.employeeName,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w600),
            ),
            ApprovalDetailRow(label: 'الفرع', value: request.branchName),
            ApprovalDetailRow(
              label: 'المبلغ',
              value: '$pounds.${piastres.toString().padLeft(2, '0')} جنيه',
            ),
            ApprovalDetailRow(label: 'السبب', value: request.reason),
            if (request.attentionMessage != null)
              ApprovalDetailRow(
                label: 'تنبيه',
                value: request.attentionMessage!,
                noteColor: Colors.red,
              ),
            const SizedBox(height: 12),
            ApprovalStatusChip(
              status: request.status,
              lastDecision: request.lastDecision,
            ),
            if (request.status == ApprovalStatus.approved &&
                request.executedAsEmployee != null)
              ApprovalDetailRow(
                label: 'نُفذت باسم',
                value: request.executedAsEmployee!,
              ),
            const SizedBox(height: 12),
            if (operationMessage != null) ...[
              const SizedBox(height: 8),
              Text(operationMessage, style: TextStyle(color: operationColor)),
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
