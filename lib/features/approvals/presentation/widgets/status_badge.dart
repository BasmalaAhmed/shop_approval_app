import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_status_style.dart';

class StatusBadge extends StatelessWidget {
  const StatusBadge({
    super.key, required this.approvalStatusStyle,
  });
  final ApprovalStatusStyle approvalStatusStyle;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: approvalStatusStyle.background,
        borderRadius: BorderRadius.circular(999),
      ),
      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(approvalStatusStyle.icon, size: 8, color: approvalStatusStyle.foreground,),
          const SizedBox(width: 6,),
          Text(
            approvalStatusStyle.label,
            style: TextStyle(
              color: approvalStatusStyle.foreground,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
