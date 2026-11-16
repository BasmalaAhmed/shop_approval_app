import 'package:shop_approval_app/models/approval_request.dart';

enum ApprovalDecisionOutcome { applied, versionConflict }

class ApprovalDecisionResult {
  final ApprovalRequest request;
  final ApprovalDecisionOutcome outcome;

  const ApprovalDecisionResult({required this.request, required this.outcome});
}
