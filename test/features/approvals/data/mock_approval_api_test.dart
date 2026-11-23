import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api_exception.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';
import '../../../helpers/approval_test_data.dart';

void main() {
  test('Response lost after execution', () async {
    final request = buildRequest();

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
    final request = buildRequest();

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
    final request = buildRequest();

    final sendRequest = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.failBeforeExecution,
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
      final request = buildRequest();

      final api = MockApprovalApi(
        initialRequests: [request],
        responseDelay: Duration.zero,
        now: () => fixedNow,
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

  test('approval stamps decidedAt from the server clock', () async {
    final request = buildRequest();
    final api = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
      now: () => fixedNow,
    );

    final result = await api.submitDecision(
      ApprovalDecisionCommand(
        requestId: request.requestId,
        decisionId: 'time-test-1',
        expectedVersion: request.version,
        decision: ApprovalDecision.approve,
      ),
    );

    expect(result.request.requestedAt, request.requestedAt);
    expect(result.request.decidedAt, fixedNow);
  });

  test('throws when the request does not exist', () async {
    final api = MockApprovalApi(
      initialRequests: [buildRequest()],
      responseDelay: Duration.zero,
    );

    await expectLater(
      api.submitDecision(
        const ApprovalDecisionCommand(
          requestId: 99,
          decisionId: 'missing-1',
          expectedVersion: 1,
          decision: ApprovalDecision.approve,
        ),
      ),
      throwsA(isA<ApprovalRequestNotFoundException>()),
    );
  });

  test('throws when a decisionId is reused with a different command', () async {
    final request = buildRequest();
    final api = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
    );

    await api.submitDecision(
      ApprovalDecisionCommand(
        requestId: request.requestId,
        decisionId: 'same-id',
        expectedVersion: request.version,
        decision: ApprovalDecision.approve,
      ),
    );

    await expectLater(
      api.submitDecision(
        ApprovalDecisionCommand(
          requestId: request.requestId,
          decisionId: 'same-id',
          expectedVersion: request.version,
          decision: ApprovalDecision.reject,
        ),
      ),
      throwsA(isA<DecisionIdReusedException>()),
    );
  });

  test(
    'external change keeps the request pending and bumps the version',
    () async {
      final request = buildRequest();
      final api = MockApprovalApi(
        initialRequests: [request],
        responseDelay: Duration.zero,
      );

      api.simulateExternalChange(request.requestId, amountInPiastres: 999900);

      final result = await api.submitDecision(
        ApprovalDecisionCommand(
          requestId: request.requestId,
          decisionId: 'stale-1',
          expectedVersion: request.version,
          decision: ApprovalDecision.approve,
        ),
      );

      expect(result.outcome, ApprovalDecisionOutcome.versionConflict);
      expect(result.request.status, ApprovalStatus.pending);
      expect(result.request.version, 2);
      expect(result.request.amountInPiastres, 999900);
    },
  );

  test('server can answer a rejection with a final rejected status', () async {
    final request = buildRequest();
    final api = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
      finalRejectionRequestIds: {request.requestId},
    );

    final result = await api.submitDecision(
      ApprovalDecisionCommand(
        requestId: request.requestId,
        decisionId: 'reject-final-1',
        expectedVersion: request.version,
        decision: ApprovalDecision.reject,
      ),
    );

    expect(result.request.status, ApprovalStatus.rejected);
  });
}
