import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_status_chip.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({super.key, required this.request});

  final ApprovalRequest request;

  @override
  Widget build(BuildContext context) {
    final pounds = request.amountInPiastres ~/ 100;
    final piastres = request.amountInPiastres % 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              request.employeeName,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600
              ),
            ),
            ApprovalDetailRow(label: 'الفرع', value: request.branchName),
            ApprovalDetailRow(
              label: 'المبلغ',
              value: '$pounds.${piastres.toString().padLeft(2, '0')} جنيه',
            ),
            ApprovalDetailRow(label: 'السبب', value: request.reason),
            const SizedBox(height: 12),
            ApprovalStatusChip(status: request.status),
          ],
        ),
      ),
    );
  }
}
