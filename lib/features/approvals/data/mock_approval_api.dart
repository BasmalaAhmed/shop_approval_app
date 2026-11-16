import 'package:shop_approval_app/features/approvals/data/approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class MockApprovalApi implements ApprovalApi {
  MockApprovalApi({
    required List<ApprovalRequest> initialRequests,
    this.scenario = MockApiScenario.normal,
    this.responseDelay = const Duration(milliseconds: 300),
  }) : _requests = {
         for (final request in initialRequests) request.requestId: request,
       };

  final MockApiScenario scenario;
  final Duration responseDelay;
  final Map<int, ApprovalRequest> _requests;
  final Map<String, _ProcessedDecision> _processedDecisions = {};

  @override
  Future<List<ApprovalRequest>> fetchRequests() async {
    await Future.delayed(responseDelay);

    return List<ApprovalRequest>.unmodifiable(_requests.values);
  }

  @override
  Future<ApprovalDecisionResult?> findDecisionById(String decisionId) async {
    await Future.delayed(responseDelay);

    return _processedDecisions[decisionId]?.result;
  }

  @override
  Future<ApprovalDecisionResult> submitDecision(
    ApprovalDecisionCommand command,
  ) async {
    await Future.delayed(responseDelay);

    final previous = _processedDecisions[command.decisionId];

    if (previous != null) {
      final sameCommand =
          previous.command.requestId == command.requestId &&
          previous.command.expectedVersion == command.expectedVersion &&
          previous.command.decision == command.decision;

      if (!sameCommand) {
        throw StateError('decisionId was reused with a different command');
      }

      return previous.result;
    }

    if (scenario == MockApiScenario.failBeforeExecution) {
      throw const MockApiNetworkException('Request failed before execution');
    }

    final currentRequest = _requests[command.requestId];

    if (currentRequest == null) {
      throw StateError('Approval request was not found');
    }

    final ApprovalDecisionResult result;

    if (currentRequest.version != command.expectedVersion ||
        currentRequest.status != ApprovalStatus.pending) {
      result = ApprovalDecisionResult(
        request: currentRequest,
        outcome: ApprovalDecisionOutcome.versionConflict,
      );
    } else {
      final updatedRequest = currentRequest.copyWith(
        version: currentRequest.version + 1,
        status: command.decision == ApprovalDecision.approve
            ? ApprovalStatus.approved
            : ApprovalStatus.draft,
        lastDecision: command.decision,
      );

      _requests[command.requestId] = updatedRequest;

      result = ApprovalDecisionResult(
        request: updatedRequest,
        outcome: ApprovalDecisionOutcome.applied,
      );
    }

    _processedDecisions[command.decisionId] = _ProcessedDecision(
      command: command,
      result: result,
    );

    if (scenario == MockApiScenario.loseResponseAfterExecution &&
        result.outcome == ApprovalDecisionOutcome.applied) {
      throw const MockApiNetworkException('Response was lost after execution');
    }

    return result;
  }
}

class _ProcessedDecision {
  final ApprovalDecisionCommand command;
  final ApprovalDecisionResult result;

  const _ProcessedDecision({required this.command, required this.result});
}

class MockApiNetworkException implements Exception {
  final String message;

  const MockApiNetworkException(this.message);

  @override
  String toString() => message;
}
