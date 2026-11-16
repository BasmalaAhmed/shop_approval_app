
import 'package:shop_approval_app/models/approval_decision.dart';

class ApprovalDecisionCommand {
  final int requestId;
  final String decisionId;
  final int expectedVersion;
  final ApprovalDecision decision;

  const ApprovalDecisionCommand({
    required this.requestId,
    required this.decisionId,
    required this.expectedVersion,
    required this.decision,
  });
}
