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
      requestedAt: DateTime(2026, 11, 23, 9, 30),
    ),
    ApprovalRequest(
      requestId: 2,
      employeeName: 'محمد محسن',
      branchName: "فرع أكتوبر",
      amountInPiastres: 159806,
      reason: "شراء مستلزمات للمحل",
      version: 1,
      status: ApprovalStatus.rejected,
      lastDecision: ApprovalDecision.reject,
      attentionMessage: 'تعدى المبلغ المحدد لهذا الشهر',
      requestedAt: DateTime(2026, 11, 22, 16, 5),
      decidedAt: DateTime(2026, 11, 22, 17, 40),
    ),
    ApprovalRequest(
      requestId: 3,
      employeeName: 'سارة عادل',
      branchName: 'فرع الإسكندرية',
      amountInPiastres: 2450000,
      reason: 'صرف سلفة مورد',
      version: 1,
      status: ApprovalStatus.pending,
      requestedAt: DateTime(2026, 11, 23, 11, 15),
      attentionMessage: 'المبلغ أعلى من المعتاد لهذا الفرع',
    ),
    ApprovalRequest(
      requestId: 4,
      employeeName: 'كريم سمير',
      branchName: 'فرع المنصورة',
      amountInPiastres: 48000,
      reason: 'مصاريف صيانة',
      version: 1,
      status: ApprovalStatus.pending,
      requestedAt: DateTime(2026, 11, 23, 12, 40),
    ),
  ];
}
