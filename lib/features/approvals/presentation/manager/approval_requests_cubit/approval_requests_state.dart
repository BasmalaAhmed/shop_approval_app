import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_request.dart';

sealed class ApprovalRequestsState {
  const ApprovalRequestsState();
}

final class ApprovalRequestsInitial extends ApprovalRequestsState {
  const ApprovalRequestsInitial();
}

final class ApprovalRequestsLoading extends ApprovalRequestsState {
  const ApprovalRequestsLoading();
}

final class ApprovalRequestsSuccess extends ApprovalRequestsState {
  final List<ApprovalRequest> requests;
  final Map<int, DecisionOperationState> decisionOperations;

  const ApprovalRequestsSuccess(
    this.requests, {
    this.decisionOperations = const {},
  });

  DecisionOperationState operationFor(int requestId) {
    return decisionOperations[requestId] ?? const DecisionIdle();
  }

  ApprovalRequestsSuccess copyWith({
    List<ApprovalRequest>? requests,
    Map<int, DecisionOperationState>? decisionOperations,
  }) {
    return ApprovalRequestsSuccess(
      requests ?? this.requests,
      decisionOperations: decisionOperations ?? this.decisionOperations,
    );
  }
}

final class ApprovalRequestsFailure extends ApprovalRequestsState {
  final String message;

  const ApprovalRequestsFailure(this.message);
}

sealed class DecisionOperationState {
  const DecisionOperationState();
}

final class DecisionIdle extends DecisionOperationState {
  const DecisionIdle();
}

final class DecisionSubmitting extends DecisionOperationState {
  final ApprovalDecisionCommand command;
  const DecisionSubmitting(this.command);
}

final class DecisionUnknownOutcome extends DecisionOperationState {
  final ApprovalDecisionCommand command;
  final String? message;
  const DecisionUnknownOutcome(this.command, {this.message});
}

final class DecisionCheckingOutcome extends DecisionOperationState {
  final ApprovalDecisionCommand command;
  const DecisionCheckingOutcome(this.command);
}

final class DecisionConfirmedSuccess extends DecisionOperationState {
  final ApprovalRequest updatedRequest;
  const DecisionConfirmedSuccess(this.updatedRequest);
}

final class DecisionConflict extends DecisionOperationState {
  final ApprovalDecisionCommand attemptedCommand;
  final ApprovalRequest latestRequest;
  const DecisionConflict({
    required this.attemptedCommand,
    required this.latestRequest,
  });
}

final class DecisionFailure extends DecisionOperationState {
  final String message;
  const DecisionFailure(this.message);
}
