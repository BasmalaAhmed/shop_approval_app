import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/core/formatters.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/sheets/confirm_sheet.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/custom_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/outline_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/sheets/reject_sheet.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class DetailsBottomBar extends StatefulWidget {
  const DetailsBottomBar({
    super.key,
    required this.request,
    required this.operation,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;

  @override
  State<DetailsBottomBar> createState() => _DetailsBottomBarState();
}

class _DetailsBottomBarState extends State<DetailsBottomBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.divider)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: _buildContent(context),
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context) {
    final cubit = context.read<ApprovalRequestsCubit>();
    final request = widget.request;
    final operation = widget.operation;

    if (!request.isPending) {
      return OutlineButton.neutral(
        label: 'العودة إلى الطلبات',
        onPressed: () => Navigator.pop(context),
      );
    }

    if (operation is DecisionSubmitting) {
      final isApprove = operation.command.decision == ApprovalDecision.approve;
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'رقم القرار ${shortDecisionId(operation.command.decisionId)} · يُعاد الإرسال بالرقم نفسه عند الحاجة',
            style: AppStyles.disclaimerText,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          CustomButton(
            label: isApprove ? 'جارٍ إرسال الموافقة...' : 'جارٍ إرسال الرفض...',
            icon: Icons.sync_rounded,
            onTap: null,
          ),
        ],
      );
    }

    if (operation is DecisionCheckingOutcome) {
      return const CustomButton(
        label: 'جارٍ التحقق من النتيجة...',
        icon: Icons.sync_rounded,
        onTap: null,
      );
    }

    if (operation is DecisionUnknownOutcome) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CustomButton(
            label: 'تحقق من النتيجة',
            icon: Icons.refresh_rounded,
            onTap: () => cubit.checkDecisionOutcome(request.requestId),
          ),
          const SizedBox(height: 10),
          OutlineButton.neutral(
            label: 'أعد إرسال نفس القرار',
            icon: Icons.replay_rounded,
            onPressed: () => cubit.retryUnknownDecision(request.requestId),
          ),
        ],
      );
    }

    if (operation is DecisionRequestChanged) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          OutlineButton.neutral(
            label: 'راجعتُ التعديل',
            icon: Icons.check_rounded,
            onPressed: () => cubit.acknowledgeChange(request.requestId),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(child: CustomButton(label: 'موافقة', onTap: null)),
              const SizedBox(width: 12),
              Expanded(child: OutlineButton.reject(onPressed: null)),
            ],
          ),
        ],
      );
    }

    final isOnline = context.watch<ConnectivityCubit>().state;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          isOnline
              ? 'عند الموافقة تُنَفَّذ العملية باسم ${widget.request.employeeName}'
              : 'لا يمكن اتخاذ قرار حتى يعود الاتصال',
          style: AppStyles.disclaimerText,
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: CustomButton(
                label: 'موافقة',
                icon: Icons.check_rounded,
                bgColor: isOnline ? AppColors.primaryTeal : Color(0XFF8C95A3),
                onTap: isOnline ? _onApprove : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: OutlineButton.reject(
                onPressed: isOnline ? _onReject : null,
              ),
            ),
          ],
        ),
      ],
    );
  }

  void _onApprove() {
    final cubit = context.read<ApprovalRequestsCubit>();
    final request = widget.request;
    void submit() =>
        cubit.submitDecision(request.requestId, ApprovalDecision.approve);
    if (request.hasAttention) {
      ConfirmSheet.show(context: context, request: request, onConfirm: submit);
    } else {
      submit();
    }
  }

  void _onReject() {
    final cubit = context.read<ApprovalRequestsCubit>();
    final request = widget.request;
    RejectSheet.show(
      context: context,
      request: request,
      onConfirm: () =>
          cubit.submitDecision(request.requestId, ApprovalDecision.reject),
    );
  }
}
