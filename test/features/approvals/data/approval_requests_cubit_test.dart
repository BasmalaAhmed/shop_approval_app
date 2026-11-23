import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api_exception.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';
import '../../../helpers/approval_test_data.dart';

class _NotFoundApi implements ApprovalApi {
  @override
  Future<List<ApprovalRequest>> fetchRequests() async => [buildRequest()];

  @override
  Future<ApprovalDecisionResult?> findDecisionById(String decisionId) async =>
      null;

  @override
  Future<ApprovalDecisionResult> submitDecision(
    ApprovalDecisionCommand command,
  ) async {
    throw ApprovalRequestNotFoundException(command.requestId);
  }
}

class _ScriptedApi implements ApprovalApi {
  List<ApprovalRequest> next = [];
  int fetchCount = 0;

  @override
  Future<List<ApprovalRequest>> fetchRequests() async {
    fetchCount++;
    return next;
  }

  @override
  Future<ApprovalDecisionResult?> findDecisionById(String decisionId) async =>
      null;

  @override
  Future<ApprovalDecisionResult> submitDecision(
    ApprovalDecisionCommand command,
  ) async {
    throw UnimplementedError();
  }
}

void main() {
  test('retrieves approve result after response lost', () async {
    final request = buildRequest();

    final api = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
    final request = buildRequest();

    final api = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.loseResponseAfterExecution,
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
      final request = buildRequest();

      final api = MockApprovalApi(
        initialRequests: [request],
        responseDelay: const Duration(milliseconds: 10),
        now: () => fixedNow,
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
    final request = buildRequest();

    final api = MockApprovalApi(
      initialRequests: [request],
      scenario: MockApiScenario.failBeforeExecution,
      responseDelay: Duration.zero,
      now: () => fixedNow,
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
    final request = buildRequest();

    final api = MockApprovalApi(
      initialRequests: [request],
      responseDelay: Duration.zero,
      now: () => fixedNow,
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

  test(
    'definite server rejection becomes a failure, not a stuck state',
    () async {
      final cubit = ApprovalRequestsCubit(
        _NotFoundApi(),
        isOnline: () => true,
        createDecisionId: () => 'decision-test-1',
      );
      addTearDown(cubit.close);

      await cubit.loadRequests();
      await cubit.submitDecision(1, ApprovalDecision.approve);

      final state = cubit.state as ApprovalRequestsSuccess;
      expect(state.operationFor(1), isA<DecisionFailure>());
    },
  );

  group('refreshRequests', () {
    test('picks up changes made elsewhere while the request is open', () async {
      final api = _ScriptedApi()..next = [buildRequest()];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.next = [buildRequest(version: 2, amountInPiastres: 999900)];
      await cubit.refreshRequests();

      final request = (cubit.state as ApprovalRequestsSuccess).requests.single;
      expect(request.version, 2);
      expect(request.amountInPiastres, 999900);
    });

    test('ignores a stale response with an older version', () async {
      final api = _ScriptedApi()..next = [buildRequest(version: 2)];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.next = [buildRequest(version: 1)];
      await cubit.refreshRequests();

      final request = (cubit.state as ApprovalRequestsSuccess).requests.single;
      expect(request.version, 2);
    });

    test('does not call the api while offline', () async {
      final api = _ScriptedApi()..next = [buildRequest()];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => false);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      await cubit.refreshRequests();

      expect(api.fetchCount, 1);
    });
  });

  group('changes while a request is open', () {
    test('flags a change that happens while viewing', () async {
      final api = _ScriptedApi()
        ..next = [buildRequest(amountInPiastres: 125500)];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();
      cubit.startViewing(1);
      await Future<void>.delayed(Duration.zero);

      api.next = [buildRequest(version: 2, amountInPiastres: 134000)];
      await cubit.refreshRequests();

      final state = cubit.state as ApprovalRequestsSuccess;
      final operation = state.operationFor(1) as DecisionRequestChanged;
      expect(operation.change.previous.amountInPiastres, 125500);
      expect(operation.change.latest.amountInPiastres, 134000);
    });

    test('does not flag a change on a request nobody is viewing', () async {
      final api = _ScriptedApi()..next = [buildRequest()];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.next = [buildRequest(version: 2, amountInPiastres: 999900)];
      await cubit.refreshRequests();

      final state = cubit.state as ApprovalRequestsSuccess;
      expect(state.operationFor(1), isA<DecisionIdle>());
    });

    test('blocks decisions until the change is acknowledged', () async {
      final api = MockApprovalApi(
        initialRequests: [buildRequest()],
        responseDelay: Duration.zero,
        now: () => fixedNow,
      );
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();
      cubit.startViewing(1);
      await Future<void>.delayed(Duration.zero);

      api.simulateExternalChange(1, amountInPiastres: 999900);
      await cubit.refreshRequests();
      await cubit.submitDecision(1, ApprovalDecision.approve);

      var state = cubit.state as ApprovalRequestsSuccess;
      expect(state.requests.single.status, ApprovalStatus.pending);
      expect(state.operationFor(1), isA<DecisionRequestChanged>());

      cubit.acknowledgeChange(1);
      await cubit.submitDecision(1, ApprovalDecision.approve);

      state = cubit.state as ApprovalRequestsSuccess;
      expect(state.requests.single.status, ApprovalStatus.approved);
      expect(state.requests.single.version, 3);
    });

    test('a conflict on a still-pending request asks for review', () async {
      final api = MockApprovalApi(
        initialRequests: [buildRequest()],
        responseDelay: Duration.zero,
      );
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.simulateExternalChange(1, amountInPiastres: 999900);
      await cubit.submitDecision(1, ApprovalDecision.approve);

      final state = cubit.state as ApprovalRequestsSuccess;
      final operation = state.operationFor(1) as DecisionRequestChanged;
      expect(operation.change.previous.amountInPiastres, 156123);
      expect(state.requests.single.amountInPiastres, 999900);
      expect(state.requests.single.status, ApprovalStatus.pending);
    });
  });
}
