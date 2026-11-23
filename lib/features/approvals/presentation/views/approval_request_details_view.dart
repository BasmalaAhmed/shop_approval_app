import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/offline_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/details_app_bar.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/details_bottom_bar.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/request_details_content.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/warning_banner.dart';

class ApprovalRequestDetailsView extends StatelessWidget {
  const ApprovalRequestDetailsView({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    final isOnline = context.watch<ConnectivityCubit>().state;
    return BlocBuilder<ApprovalRequestsCubit, ApprovalRequestsState>(
      builder: (context, state) {
        if (state is ApprovalRequestsSuccess) {
          final request = state.requests
              .where((item) => item.requestId == requestId)
              .firstOrNull;

          if (request != null) {
            final operation = state.operationFor(requestId);
            return Scaffold(
              backgroundColor: AppColors.scaffoldBackground,
              body: SafeArea(
                child: Column(
                  children: [
                    if (!isOnline) ...[
                      const OfflineBanner(),
                      const SizedBox(height: 12),
                    ],
                    DetailsAppBar(request: request),
                    Expanded(
                      child: RequestDetailsContent(
                        request: request,
                        operation: operation,
                      ),
                    ),
                    DetailsBottomBar(request: request, operation: operation),
                  ],
                ),
              ),
            );
          }
        }
        if (state is ApprovalRequestsFailure) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: const DetailsAppBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: WarningBanner(
                  title: 'تعذر تحميل الطلبات',
                  subtitle: state.message,
                ),
              ),
            ),
          );
        }
        if (state is ApprovalRequestsSuccess) {
          return Scaffold(
            backgroundColor: AppColors.scaffoldBackground,
            appBar: const DetailsAppBar(),
            body: Center(child: const Text('الطلب غير موجود')),
          );
        }
        return const CircularProgressIndicator();
      },
    );
  }
}
