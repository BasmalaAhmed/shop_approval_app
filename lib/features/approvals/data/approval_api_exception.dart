class ApprovalRequestNotFoundException implements Exception {
  final int requestId;

  const ApprovalRequestNotFoundException(this.requestId);

  @override
  String toString() => 'Approval request $requestId was not found';
}

class DecisionIdReusedException implements Exception {
  final String decisionId;

  const DecisionIdReusedException(this.decisionId);

  @override
  String toString() =>
      'decisionId $decisionId was reused with a different command';
}
