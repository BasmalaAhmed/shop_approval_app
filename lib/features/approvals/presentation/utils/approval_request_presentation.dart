import 'package:shop_approval_app/core/formatters.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_request.dart';

extension ApprovalRequestPresentation on ApprovalRequest {
  bool get hasAttention => attentionMessage?.trim().isNotEmpty == true;

  bool get isPending => status == ApprovalStatus.pending;

  bool get wasRejected =>
      status == ApprovalStatus.rejected ||
      
          lastDecision == ApprovalDecision.reject;

  String get formattedAmount => formatPiastres(amountInPiastres);
}
