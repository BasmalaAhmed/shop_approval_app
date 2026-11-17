import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_notice.dart';
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

    Widget? operationStatus;

    if (operation is DecisionSubmitting) {
      operationStatus = const Text('جارٍ إرسال القرار...');
    } else if (operation is DecisionCheckingOutcome) {
      operationStatus = const Text('جارٍ التحقق من النتيجة...');
    } else if (operation is DecisionUnknownOutcome) {
      final unknown = operation as DecisionUnknownOutcome;
      operationStatus = ApprovalNotice(
        title: 'النتيجة غير مؤكدة',
        message: unknown.message ?? 'تعذر تأكيد نتيجة القرار.',
      );
    } else if (operation is DecisionConflict) {
      operationStatus = const ApprovalNotice(
        title: 'تم تحديث الطلب',
        message: 'تغيّرت بيانات الطلب من جهاز آخر. يرجى مراجعة البيانات.',
      );
    } else if (operation is DecisionFailure) {
      final failure = operation as DecisionFailure;
      operationStatus = ApprovalNotice(
        title: 'تعذر تنفيذ القرار',
        message: failure.message,
      );
    }

    return Card(
      color: Color(0XFFEAEFD3),
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
            if (request.attentionMessage?.trim().isNotEmpty == true)
              ApprovalNotice(
                title: 'تنبيه',
                message: request.attentionMessage!,
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
            if (operationStatus != null) ...[
              const SizedBox(height: 8),
              operationStatus,
            ],
            const SizedBox(height: 12),
          ],
        ),
      ),
    );
  }
}
