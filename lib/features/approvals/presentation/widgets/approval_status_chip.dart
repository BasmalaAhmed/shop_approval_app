import 'package:flutter/material.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalStatusChip extends StatelessWidget {
  const ApprovalStatusChip({
    super.key,
    required this.status,
    required this.lastDecision,
  });
  final ApprovalStatus status;
  final ApprovalDecision? lastDecision;

  String _statusLabel(ApprovalStatus status, ApprovalDecision? lastDecision) {
    if (status == ApprovalStatus.draft &&
        lastDecision == ApprovalDecision.reject) {
      return 'مرفوض - عادت لمسودة';
    }
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
        _statusLabel(status, lastDecision),
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      ),
    );
  }
}
