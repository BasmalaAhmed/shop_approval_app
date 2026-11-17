import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_request.dart';

List<ApprovalRequest> createMockApprovalRequests() {
  return [
    ApprovalRequest(
      requestId: 1,
      employeeName: 'أحمد محمود',
      branchName: "فرع مدينة نصر",
      amountInPiastres: 125500,
      reason: "شراء مستلزمات للمحل",
      version: 1,
      status: ApprovalStatus.pending,
    ),
    ApprovalRequest(
      requestId: 2,
      employeeName: 'محمد محسن',
      branchName: "فرع أكتوبر",
      amountInPiastres: 159806,
      reason: "شراء مستلزمات للمحل",
      version: 1,
      status: ApprovalStatus.draft,
      lastDecision: ApprovalDecision.reject,
      attentionMessage: 'لا يمكن الموافقة',
    ),
  ];
}
