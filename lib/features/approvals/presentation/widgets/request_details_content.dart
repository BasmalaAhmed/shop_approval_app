import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/approval_status_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/info_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/cards/details_card.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/cards/reason_card.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/warning_banner.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class RequestDetailsContent extends StatelessWidget {
  const RequestDetailsContent({
    super.key,
    required this.request,
    required this.operation,
  });

  final ApprovalRequest request;
  final DecisionOperationState operation;

  @override
  Widget build(BuildContext context) {
    final attention = request.attentionMessage;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      children: [
        ApprovalStatusBanner(request: request, operation: operation),
        DetailsCard(request: request, operation: operation),
        const SizedBox(height: 12),
        if (request.hasAttention && attention != null) ...[
          WarningBanner(
            title: attention,
            subtitle: request.isPending
                ? 'راجع التنبيه قبل اتخاذ القرار.'
                : null,
          ),
          const SizedBox(height: 12),
        ],
        ReasonCard(reason: request.reason),
        const SizedBox(height: 12),
        if (!context.watch<ConnectivityCubit>().state) ...[
          const InfoBanner(
            title: 'لا يمكن اتخاذ قرار دون اتصال',
            subtitle: 'نتأكد أولًا أن أحدًا لم يتخذ قرارًا قبلك.',
            icon: Icons.wifi_off_outlined,
            titleColor: Color(0XFF6B7280),
            bgColor: Color(0XFFF3F4F6),
            borderColor: Color(0XFF6B7280),
          ),
        ],
      ],
    );
  }
}
