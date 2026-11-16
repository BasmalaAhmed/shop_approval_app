import 'package:flutter/material.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestCard extends StatelessWidget {
  const ApprovalRequestCard({super.key, required this.request});

  final ApprovalRequest request;

  String _statusLabel(ApprovalStatus status) {
    switch (status) {
      case ApprovalStatus.pending:
        return 'في انتظار الموافقة';
      case ApprovalStatus.approved:
        return 'تمت الموافقة';
      case ApprovalStatus.rejected:
        return 'مرفوض';
      case ApprovalStatus.draft:
        return 'مسودة';
    }
  }

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
            Chip(label: Text(_statusLabel(request.status))),
          ],
        ),
      ),
    );
  }
}
