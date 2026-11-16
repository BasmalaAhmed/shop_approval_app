import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_status_chip.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestDetailsPage extends StatelessWidget {
  const ApprovalRequestDetailsPage({super.key, required this.request});

  final ApprovalRequest request;

  @override
  Widget build(BuildContext context) {
    final pounds = request.amountInPiastres ~/ 100;
    final piastres = request.amountInPiastres % 100;

    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الطلب')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ApprovalDetailRow(
                label: 'اسم الموظف',
                value: request.employeeName,
              ),
              const SizedBox(height: 12),
              ApprovalDetailRow(label: 'الفرع', value: request.branchName),
              const SizedBox(height: 12),
              ApprovalDetailRow(
                label: 'المبلغ',
                value: '$pounds.${piastres.toString().padLeft(2, '0')} جنيه',
              ),
              const SizedBox(height: 12),
              ApprovalDetailRow(label: 'السبب', value: request.reason),
              const SizedBox(height: 12),
              ApprovalStatusChip(status: request.status),
            ],
          ),
        ),
      ),
    );
  }
}
