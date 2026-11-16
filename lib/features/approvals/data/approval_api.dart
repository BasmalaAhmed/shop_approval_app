import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';

abstract class ApprovalApi {
  Future<List<ApprovalRequest>> fetchRequests();

  Future<ApprovalDecisionResult> submitDecision(
    ApprovalDecisionCommand command,
  );

  Future<ApprovalDecisionResult?> findDecisionById(String decisionId);
}
