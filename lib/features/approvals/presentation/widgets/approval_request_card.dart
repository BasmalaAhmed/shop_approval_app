import 'package:flutter/material.dart';
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
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text("الفرع: ${request.branchName}"),
            const SizedBox(height: 8),
            Text('المبلغ: $pounds.${piastres.toString().padLeft(2, '0')} جنيه'),
            const SizedBox(height: 8),
            Text("السبب: ${request.reason}"),
            const SizedBox(height: 12),
            ApprovalStatusChip(status: request.status),
          ],
        ),
      ),
    );
  }
}
