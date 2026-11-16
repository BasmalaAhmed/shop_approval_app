import 'package:flutter/material.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalStatusChip extends StatelessWidget {
  const ApprovalStatusChip({super.key, required this.status});
  final ApprovalStatus status;

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
    return Chip(
      label: Text(
        _statusLabel(status),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
