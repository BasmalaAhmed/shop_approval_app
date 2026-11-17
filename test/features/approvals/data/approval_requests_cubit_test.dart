import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_request.dart';

void main() {
  test('retrieves approve result after response lost', () async {
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
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
    );

    final cubit = ApprovalRequestsCubit(
      api,
      isOnline: () => true,
      createDecisionId: () => 'decision-test-1',
    );

    addTearDown(cubit.close);

    await cubit.loadRequests();
    await cubit.submitDecision(request.requestId, ApprovalDecision.approve);

    final stateAfterSubmit = cubit.state;
    expect(stateAfterSubmit, isA<ApprovalRequestsSuccess>());

    final successAfterSubmit = stateAfterSubmit as ApprovalRequestsSuccess;
    final operationAfterSubmit = successAfterSubmit.operationFor(
      request.requestId,
    );

    expect(operationAfterSubmit, isA<DecisionUnknownOutcome>());

    final unknownOutcome = operationAfterSubmit as DecisionUnknownOutcome;
    expect(unknownOutcome.command.decisionId, 'decision-test-1');

    await cubit.checkDecisionOutcome(request.requestId);

    final stateAfterCheck = cubit.state;
    expect(stateAfterCheck, isA<ApprovalRequestsSuccess>());

    final successAfterCheck = stateAfterCheck as ApprovalRequestsSuccess;
    final operationAfterCheck = successAfterCheck.operationFor(
      request.requestId,
    );

    expect(operationAfterCheck, isA<DecisionConfirmedSuccess>());

    final confirmedSuccess = operationAfterCheck as DecisionConfirmedSuccess;
    expect(confirmedSuccess.updatedRequest.status, ApprovalStatus.approved);
    expect(confirmedSuccess.updatedRequest.version, 2);
    expect(successAfterCheck.requests.single.status, ApprovalStatus.approved);
    expect(successAfterCheck.requests.single.version, 2);
    expect(
      successAfterCheck.requests.single.executedAsEmployee,
      request.employeeName,
    );
  });

  test('retries unknown decision with the same decision ID', () async {
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
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
    );

    var generatedIdCount = 0;

    final cubit = ApprovalRequestsCubit(
      api,
      isOnline: () => true,
      createDecisionId: () {
        generatedIdCount++;
        return 'decision-test-1';
      },
    );

    addTearDown(cubit.close);

    await cubit.loadRequests();
    await cubit.submitDecision(request.requestId, ApprovalDecision.approve);

    expect(cubit.state, isA<ApprovalRequestsSuccess>());
    final stateAfterSubmit = cubit.state as ApprovalRequestsSuccess;
    expect(
      stateAfterSubmit.operationFor(request.requestId),
      isA<DecisionUnknownOutcome>(),
    );

    await cubit.retryUnknownDecision(request.requestId);

    expect(generatedIdCount, 1);
    expect(cubit.state, isA<ApprovalRequestsSuccess>());

    final finalState = cubit.state as ApprovalRequestsSuccess;
    final finalOperation = finalState.operationFor(request.requestId);

    expect(finalOperation, isA<DecisionConfirmedSuccess>());
    expect(finalState.requests.single.status, ApprovalStatus.approved);
    expect(finalState.requests.single.version, 2);
  });

  test(
    'ignores duplicate submissions while a decision is submitting',
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
        responseDelay: const Duration(milliseconds: 10),
      );

      var generatedIdCount = 0;

      final cubit = ApprovalRequestsCubit(
        api,
        isOnline: () => true,
        createDecisionId: () {
          generatedIdCount++;
          return 'decision-test-1';
        },
      );

      addTearDown(cubit.close);

      await cubit.loadRequests();

      await Future.wait([
        cubit.submitDecision(request.requestId, ApprovalDecision.approve),
        cubit.submitDecision(request.requestId, ApprovalDecision.approve),
      ]);

      expect(generatedIdCount, 1);
      expect(cubit.state, isA<ApprovalRequestsSuccess>());

      final finalState = cubit.state as ApprovalRequestsSuccess;
      final operation = finalState.operationFor(request.requestId);

      expect(operation, isA<DecisionConfirmedSuccess>());
      expect(finalState.requests.single.status, ApprovalStatus.approved);
      expect(finalState.requests.single.version, 2);
    },
  );

  test('does not submit a new decision while offline', () async {
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
      scenario: MockApiScenario.failBeforeExecution,
      responseDelay: Duration.zero,
    );

    var generatedIdCount = 0;

    final cubit = ApprovalRequestsCubit(
      api,
      isOnline: () => false,
      createDecisionId: () {
        generatedIdCount++;
        return 'decision-test-1';
      },
    );

    addTearDown(cubit.close);

    await cubit.loadRequests();
    await cubit.submitDecision(request.requestId, ApprovalDecision.approve);

    expect(generatedIdCount, 0);
    expect(cubit.state, isA<ApprovalRequestsSuccess>());

    final finalState = cubit.state as ApprovalRequestsSuccess;
    expect(finalState.operationFor(request.requestId), isA<DecisionFailure>());
    expect(finalState.requests.single.status, ApprovalStatus.pending);
    expect(finalState.requests.single.version, 1);
  });

  test('updates the request when another device decided first', () async {
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

    final cubit = ApprovalRequestsCubit(
      api,
      isOnline: () => true,
      createDecisionId: () => 'owner-decision-1',
    );

    addTearDown(cubit.close);

    await cubit.loadRequests();

    await api.submitDecision(
      ApprovalDecisionCommand(
        requestId: request.requestId,
        decisionId: 'other-device-decision-1',
        expectedVersion: request.version,
        decision: ApprovalDecision.approve,
      ),
    );

    await cubit.submitDecision(request.requestId, ApprovalDecision.reject);

    expect(cubit.state, isA<ApprovalRequestsSuccess>());

    final finalState = cubit.state as ApprovalRequestsSuccess;
    final operation = finalState.operationFor(request.requestId);

    expect(operation, isA<DecisionConflict>());

    final conflict = operation as DecisionConflict;
    expect(conflict.latestRequest.status, ApprovalStatus.approved);
    expect(conflict.latestRequest.version, 2);
    expect(finalState.requests.single.status, ApprovalStatus.approved);
    expect(finalState.requests.single.version, 2);
  });
}
