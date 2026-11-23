import 'dart:math' as math;

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api_exception.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestsCubit extends Cubit<ApprovalRequestsState> {
  final ApprovalApi api;
  final bool Function() _isOnline;
  final String Function() _createDecisionId;
  ApprovalRequestsCubit(
    this.api, {
    bool Function()? isOnline,
    String Function()? createDecisionId,
  }) : _isOnline = isOnline ?? _assumeOnlineForMock,
       _createDecisionId = createDecisionId ?? _generateDecisionId,
       super(const ApprovalRequestsInitial());

  static bool _assumeOnlineForMock() => true;

  static String _generateDecisionId() {
    final random = math.Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));

    return bytes.map((byte) => byte.toRadixString(16).padLeft(2, '0')).join();
  }

  Future<void> loadRequests() async {
    final previousState = state;
    final hadRequests = previousState is ApprovalRequestsSuccess;

    if (!hadRequests) {
      emit(const ApprovalRequestsLoading());
    }

    try {
      final requests = await api.fetchRequests();

      final latestState = state;
      final operations = latestState is ApprovalRequestsSuccess
          ? Map<int, DecisionOperationState>.from(
              latestState.decisionOperations,
            )
          : <int, DecisionOperationState>{};
      operations.removeWhere(
        (_, operation) => operation is DecisionConfirmedSuccess,
      );

      emit(
        ApprovalRequestsSuccess(
          requests,
          decisionOperations: Map<int, DecisionOperationState>.unmodifiable(
            operations,
          ),
        ),
      );
    } on Exception {
      if (!hadRequests) {
        emit(
          const ApprovalRequestsFailure('تعذر تحميل الطلبات. حاول مرة أخرى'),
        );
      }
    }
  }

  Future<void> refreshRequests() async {
    if (state is! ApprovalRequestsSuccess || !_isOnline()) {
      return;
    }

    try {
      final fetched = await api.fetchRequests();

      final currentState = state;

      if (currentState is! ApprovalRequestsSuccess) {
        return;
      }

      final localById = {
        for (final request in currentState.requests) request.requestId: request,
      };

      final merged = fetched
          .map((remote) {
            final local = localById[remote.requestId];

            return local != null && local.version > remote.version
                ? local
                : remote;
          })
          .toList(growable: false);

      emit(
        currentState.copyWith(
          requests: List<ApprovalRequest>.unmodifiable(merged),
        ),
      );
    } on Exception {
      return;
    }
  }

  void _setDecisionOperation(int requestId, DecisionOperationState operation) {
    final currentState = state;

    if (currentState is! ApprovalRequestsSuccess) {
      return;
    }

    final updatedOperations = Map<int, DecisionOperationState>.from(
      currentState.decisionOperations,
    );

    if (operation is DecisionIdle) {
      updatedOperations.remove(requestId);
    } else {
      updatedOperations[requestId] = operation;
    }

    emit(
      currentState.copyWith(
        decisionOperations: Map<int, DecisionOperationState>.unmodifiable(
          updatedOperations,
        ),
      ),
    );
  }

  void _setRequestAndDecisionOperation(
    ApprovalRequest updatedRequest,
    DecisionOperationState operation,
  ) {
    final currentState = state;

    if (currentState is! ApprovalRequestsSuccess) {
      return;
    }

    final updatedRequests = currentState.requests
        .map(
          (request) => request.requestId == updatedRequest.requestId
              ? updatedRequest
              : request,
        )
        .toList(growable: false);

    final updatedOperations = Map<int, DecisionOperationState>.from(
      currentState.decisionOperations,
    );

    if (operation is DecisionIdle) {
      updatedOperations.remove(updatedRequest.requestId);
    } else {
      updatedOperations[updatedRequest.requestId] = operation;
    }

    emit(
      currentState.copyWith(
        requests: List<ApprovalRequest>.unmodifiable(updatedRequests),
        decisionOperations: Map<int, DecisionOperationState>.unmodifiable(
          updatedOperations,
        ),
      ),
    );
  }

  Future<void> submitDecision(int requestId, ApprovalDecision decision) async {
    final currentState = state;

    if (currentState is! ApprovalRequestsSuccess) {
      return;
    }

    final matchingRequests = currentState.requests.where(
      (request) => request.requestId == requestId,
    );

    if (matchingRequests.isEmpty) {
      return;
    }

    final request = matchingRequests.first;

    if (request.status != ApprovalStatus.pending) {
      return;
    }

    final operation = currentState.operationFor(requestId);

    if (operation is DecisionSubmitting ||
        operation is DecisionCheckingOutcome ||
        operation is DecisionUnknownOutcome) {
      return;
    }

    if (!_isOnline()) {
      _setDecisionOperation(
        requestId,
        const DecisionFailure('لا يمكن إرسال قرار بدون اتصال بالإنترنت'),
      );
      return;
    }

    final command = ApprovalDecisionCommand(
      requestId: request.requestId,
      decisionId: _createDecisionId(),
      expectedVersion: request.version,
      decision: decision,
    );

    _setDecisionOperation(requestId, DecisionSubmitting(command));

    try {
      final result = await api.submitDecision(command);

      switch (result.outcome) {
        case ApprovalDecisionOutcome.applied:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConfirmedSuccess(result.request),
          );

        case ApprovalDecisionOutcome.versionConflict:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConflict(
              attemptedCommand: command,
              latestRequest: result.request,
            ),
          );
      }
    } on ApprovalRequestNotFoundException {
      _setDecisionOperation(
        requestId,
        const DecisionFailure('الطلب لم يعد موجودًا'),
      );
    } on DecisionIdReusedException {
      _setDecisionOperation(
        requestId,
        const DecisionFailure('تعذر تنفيذ القرار. حاول مرة أخرى'),
      );
    } on Exception {
      _setDecisionOperation(
        requestId,
        DecisionUnknownOutcome(
          command,
          message: _unknownOutcomeMessage(command.decision),
        ),
      );
    }
  }

  Future<void> checkDecisionOutcome(int requestId) async {
    final currentState = state;

    if (currentState is! ApprovalRequestsSuccess) {
      return;
    }

    final operation = currentState.operationFor(requestId);

    if (operation is! DecisionUnknownOutcome) {
      return;
    }

    final command = operation.command;

    if (!_isOnline()) {
      _setDecisionOperation(
        requestId,
        DecisionUnknownOutcome(
          command,
          message: 'لا يوجد اتصال للتحقق من نتيجة القرار',
        ),
      );
      return;
    }

    _setDecisionOperation(requestId, DecisionCheckingOutcome(command));

    try {
      final result = await api.findDecisionById(command.decisionId);

      if (result == null) {
        _setDecisionOperation(
          requestId,
          DecisionUnknownOutcome(
            command,
            message: 'لم تظهر نتيجة القرار بعد. يمكنك التحقق مرة أخرى.',
          ),
        );
        return;
      }

      switch (result.outcome) {
        case ApprovalDecisionOutcome.applied:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConfirmedSuccess(result.request),
          );

        case ApprovalDecisionOutcome.versionConflict:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConflict(
              attemptedCommand: command,
              latestRequest: result.request,
            ),
          );
      }
    } on Exception {
      _setDecisionOperation(
        requestId,
        DecisionUnknownOutcome(
          command,
          message: _unknownOutcomeMessage(command.decision),
        ),
      );
    }
  }

  Future<void> retryUnknownDecision(int requestId) async {
    final currentState = state;

    if (currentState is! ApprovalRequestsSuccess) {
      return;
    }

    final operation = currentState.operationFor(requestId);

    if (operation is! DecisionUnknownOutcome) {
      return;
    }

    final command = operation.command;

    if (!_isOnline()) {
      _setDecisionOperation(
        requestId,
        DecisionUnknownOutcome(
          command,
          message: 'لا يوجد اتصال لإعادة إرسال القرار',
        ),
      );
      return;
    }

    _setDecisionOperation(requestId, DecisionSubmitting(command));

    try {
      final result = await api.submitDecision(command);

      switch (result.outcome) {
        case ApprovalDecisionOutcome.applied:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConfirmedSuccess(result.request),
          );

        case ApprovalDecisionOutcome.versionConflict:
          _setRequestAndDecisionOperation(
            result.request,
            DecisionConflict(
              attemptedCommand: command,
              latestRequest: result.request,
            ),
          );
      }
    } on ApprovalRequestNotFoundException {
      _setDecisionOperation(
        requestId,
        const DecisionFailure('الطلب لم يعد موجودًا'),
      );
    } on DecisionIdReusedException {
      _setDecisionOperation(
        requestId,
        const DecisionFailure('تعذر تنفيذ القرار. حاول مرة أخرى'),
      );
    } on Exception {
      _setDecisionOperation(
        requestId,
        DecisionUnknownOutcome(
          command,
          message: _unknownOutcomeMessage(command.decision),
        ),
      );
    }
  }

  String _unknownOutcomeMessage(ApprovalDecision decision) {
    final decisionName = decision == ApprovalDecision.approve
        ? 'الموافقة'
        : 'الرفض';

    return 'تعذر تأكيد نتيجة $decisionName. يرجى التحقق من النتيجة قبل اتخاذ قرار جديد.';
  }
}
