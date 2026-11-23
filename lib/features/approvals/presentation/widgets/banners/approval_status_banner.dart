import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/info_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/request_changed_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/tinted_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/warning_banner.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalStatusBanner extends StatelessWidget {
  const ApprovalStatusBanner({
    super.key,
    required this.request,
    required this.operation,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;

  @override
  Widget build(BuildContext context) {
    final bannerWidget = _buildBanner();
    if (bannerWidget == null) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: bannerWidget,
    );
  }

  Widget? _buildBanner() {
    if (operation is DecisionCheckingOutcome) {
      return UnconfirmedOutcomeBanner(
        title: 'جارِ التحقق من نتيجة القرار',
        message:
            'قد يكون القرار وصل للخادم لكن الرد فُقد. لن نعيد الإرسال؛ سنسأل الخادم عن النتيجة.',
        decisionId: (operation as DecisionCheckingOutcome).command.decisionId,
      );
    }

    if (operation is DecisionUnknownOutcome) {
      final op = operation as DecisionUnknownOutcome;
      return UnconfirmedOutcomeBanner(
        title: 'النتيجة غير مؤكدة',
        message: op.message ?? 'تعذر تأكيد نتيجة القرار.',
        decisionId: op.command.decisionId,
      );
    }

    if (operation is DecisionRequestChanged) {
      return RequestChangedBanner(
        change: (operation as DecisionRequestChanged).change,
      );
    }

    if (operation is DecisionConflict) {
      return const InfoBanner(
        icon: Icons.tablet_mac_rounded,
        title: 'اتُّخِذ القرار من جهاز آخر',
        subtitle: 'تم اتخاذ قرار على هذا الطلب من جهاز آخر. لا يلزم أي إجراء.',
        titleColor: AppColors.textPrimary,
        bgColor: Color(0xFFF8FAFC),
        borderColor: AppColors.offlineGreyBorder,
      );
    }

    if (operation is DecisionFailure) {
      return WarningBanner(
        title: 'تعذر تنفيذ القرار',
        subtitle: (operation as DecisionFailure).message,
      );
    }

    if (request.status == ApprovalStatus.approved) {
      final executedAs = request.executedAsEmployee;
      return InfoBanner(
        subtitle: executedAs != null
            ? 'نُفِّذت العملية باسم $executedAs'
            : 'تمت الموافقة على الطلب',
        title: 'تمت الموافقة',
        icon: Icons.check_rounded,
        titleColor: AppColors.approvedText,
        bgColor: AppColors.approvedBg,
        borderColor: AppColors.approvedBorder,
      );
    }

    if (request.wasRejected) {
      return InfoBanner(
        title: 'تم رفض الطلب',
        subtitle: request.status == ApprovalStatus.rejected
            ? 'عاد الطلب مسودة عند ${request.employeeName}'
            : 'تم رفض هذا الطلب',
        titleColor: AppColors.textPrimary,
        bgColor: const Color(0xFFF8FAFC),
        borderColor: AppColors.offlineGreyBorder,
      );
    }

    return null;
  }
}
