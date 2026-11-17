import 'package:shop_approval_app/models/approval_request.dart';

enum ApprovalActionStatus { submitting, outcomeUnknown }

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
  final Map<int, ApprovalActionStatus> actionStatuses;

  const ApprovalRequestsSuccess(
    this.requests, {
    this.actionStatuses = const {},
  });
}

final class ApprovalRequestsFailure extends ApprovalRequestsState {
  final String message;

  const ApprovalRequestsFailure(this.message);
}
