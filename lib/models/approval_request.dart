import 'package:shop_approval_app/models/approval_decision.dart';

enum ApprovalStatus { pending, approved, rejected, draft }

class ApprovalRequest {
  final int requestId;
  final String employeeName;
  final String branchName;
  final int amountInPiastres;
  final String reason;
  final int version;
  final ApprovalStatus status;
  final ApprovalDecision? lastDecision;
  final String? attentionMessage;
  final String? executedAsEmployee;
  final DateTime requestedAt;
  final DateTime? decidedAt;

  ApprovalRequest({
    required this.requestId,
    required this.employeeName,
    required this.branchName,
    required this.amountInPiastres,
    required this.reason,
    required this.version,
    required this.status,
    this.lastDecision,
    this.attentionMessage,
    this.executedAsEmployee,
    required this.requestedAt,
    this.decidedAt,
  });

  ApprovalRequest copyWith({
    int? version,
    ApprovalStatus? status,
    ApprovalDecision? lastDecision,
    String? attentionMessage,
    String? executedAsEmployee,
    DateTime? decidedAt,
  }) {
    return ApprovalRequest(
      requestId: requestId,
      employeeName: employeeName,
      branchName: branchName,
      amountInPiastres: amountInPiastres,
      reason: reason,
      version: version ?? this.version,
      status: status ?? this.status,
      lastDecision: lastDecision ?? this.lastDecision,
      attentionMessage: attentionMessage ?? this.attentionMessage,
      executedAsEmployee: executedAsEmployee ?? this.executedAsEmployee,
      requestedAt: requestedAt,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }
}
