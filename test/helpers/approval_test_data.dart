import 'package:shop_approval_app/models/approval_request.dart';

ApprovalRequest buildRequest({
  int requestId = 1,
  int version = 1,
  ApprovalStatus status = ApprovalStatus.pending,
  int amountInPiastres = 156123,
  String? attentionMessage,
}) {
  return ApprovalRequest(
    requestId: requestId,
    employeeName: 'أحمد محمود',
    branchName: 'مدينة نصر',
    amountInPiastres: amountInPiastres,
    reason: 'شراء مستلزمات للمحل',
    version: version,
    status: status,
    requestedAt: DateTime(2026, 11, 23, 9, 30),
    attentionMessage: attentionMessage,
  );
}

final fixedNow = DateTime(2026, 11, 23, 10, 0);