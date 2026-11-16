enum ApprovalStatus { pending, approved, rejected, draft }

class ApprovalRequest {
  final int requestId;
  final String employeeName;
  final String branchName;
  final int amountInPiastres;
  final String reason;
  final int version;
  final ApprovalStatus status;

  ApprovalRequest({
    required this.requestId,
    required this.employeeName,
    required this.branchName,
    required this.amountInPiastres,
    required this.reason,
    required this.version,
    required this.status,
  });
}
