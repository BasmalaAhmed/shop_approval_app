import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';

void main() {
  test('Response lost after execution', () async {
    final request = ApprovalRequest(
      requestId: 1,
      employeeName: 'احمد محمود',
      branchName: 'مدينة نصر',
      amountInPiastres: 156123,
      reason: 'شراء مستلزمات للمحل',
      version: 1,
      status: ApprovalStatus.pending,
    );

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
    );

    final command = ApprovalDecisionCommand(
      requestId: request.requestId,
      decisionId: 'decision-1',
      expectedVersion: request.version,
      decision: ApprovalDecision.approve,
    );

    await expectLater(
      sendRequest.submitDecision(command),
      throwsA(isA<MockApiNetworkException>()),
    );

    final recoveredResult = await sendRequest.findDecisionById(
      command.decisionId,
    );

    expect(recoveredResult, isNotNull);

    final result = recoveredResult!;

    expect(result.outcome, ApprovalDecisionOutcome.applied);
    expect(result.request.status, ApprovalStatus.approved);
    expect(result.request.version, 2);

    final retryResult = await sendRequest.submitDecision(command);

    expect(retryResult.request.version, 2);

    expect(result.request.lastDecision, ApprovalDecision.approve);
  });

  test('two different decision from different devices', () async {
    final request = ApprovalRequest(
      requestId: 1,
      employeeName: 'احمد محمود',
      branchName: 'مدينة نصر',
      amountInPiastres: 156123,
      reason: 'شراء مستلزمات للمحل',
      version: 1,
      status: ApprovalStatus.pending,
    );

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
    );

    final firstCommand = ApprovalDecisionCommand(
      requestId: request.requestId,
      decisionId: 'device-1-decision-1',
      expectedVersion: request.version,
      decision: ApprovalDecision.approve,
    );
    final secondCommand = ApprovalDecisionCommand(
      requestId: request.requestId,
      decisionId: 'device-2-decision-1',
      expectedVersion: request.version,
      decision: ApprovalDecision.reject,
    );

    final firstResult = await sendRequest.submitDecision(firstCommand);
    final secondResult = await sendRequest.submitDecision(secondCommand);

    expect(firstResult.outcome, ApprovalDecisionOutcome.applied);
    expect(secondResult.outcome, ApprovalDecisionOutcome.versionConflict);
    expect(secondResult.request.status, ApprovalStatus.approved);
    expect(secondResult.request.version, 2);
    expect(secondResult.request.lastDecision, ApprovalDecision.approve);
  });

  test('Network failure before execution', () async {
    final request = ApprovalRequest(
      requestId: 1,
      employeeName: 'احمد محمود',
      branchName: 'مدينة نصر',
      amountInPiastres: 156123,
      reason: 'شراء مستلزمات للمحل',
      version: 1,
      status: ApprovalStatus.pending,
    );

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.failBeforeExecution,
      responseDelay: Duration.zero,
    );

    final command = ApprovalDecisionCommand(
      requestId: request.requestId,
      decisionId: 'decision-1',
      expectedVersion: request.version,
      decision: ApprovalDecision.approve,
    );

    await expectLater(
      sendRequest.submitDecision(command),
      throwsA(isA<MockApiNetworkException>()),
    );

    final results = await sendRequest.fetchRequests();
    final result = results.single;

    expect(result.status, ApprovalStatus.pending);
    expect(result.version, 1);

    final decisionResult = await sendRequest.findDecisionById(
      command.decisionId,
    );

    expect(decisionResult, isNull);
    expect(result.lastDecision, isNull);
  });

  test(
    'rejection returns request to draft without execution employee',
    () async {
      final request = ApprovalRequest(
        requestId: 1,
        employeeName: 'أحمد محمود',
        branchName: 'مدينة نصر',
        amountInPiastres: 156123,
        reason: 'شراء مستلزمات للمحل',
        version: 1,
        status: ApprovalStatus.pending,
      );

      final api = MockApprovalApi(
        initialRequests: [request],
        responseDelay: Duration.zero,
      );

      final result = await api.submitDecision(
        ApprovalDecisionCommand(
          requestId: request.requestId,
          decisionId: 'reject-test-1',
          expectedVersion: request.version,
          decision: ApprovalDecision.reject,
        ),
      );

      expect(result.outcome, ApprovalDecisionOutcome.applied);
      expect(result.request.status, ApprovalStatus.draft);
      expect(result.request.lastDecision, ApprovalDecision.reject);
      expect(result.request.version, 2);
      expect(result.request.executedAsEmployee, isNull);
    },
  );
}
