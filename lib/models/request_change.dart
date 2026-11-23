import 'package:shop_approval_app/models/approval_request.dart';

class RequestChange {
  const RequestChange({required this.previous, required this.latest});

  final ApprovalRequest previous;
  final ApprovalRequest latest;

  bool get amountChanged =>
      previous.amountInPiastres != latest.amountInPiastres;
  bool get branchChanged => previous.branchName != latest.branchName;
  bool get employeeChanged => previous.employeeName != latest.employeeName;
  bool get reasonChanged => previous.reason != latest.reason;
  bool get attentionChanged =>
      previous.attentionMessage != latest.attentionMessage;

  bool get hasVisibleChanges =>
      amountChanged ||
      branchChanged ||
      employeeChanged ||
      reasonChanged ||
      attentionChanged;
}
