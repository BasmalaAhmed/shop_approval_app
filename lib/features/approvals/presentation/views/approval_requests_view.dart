import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/core/app_colors.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_request_details_view.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/offline_banner.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/custom_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/cards/approval_request_card.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/tab_bar_widget.dart';

class ApprovalRequestsView extends StatefulWidget {
  const ApprovalRequestsView({super.key});

  @override
  State<ApprovalRequestsView> createState() => _ApprovalRequestsViewState();
}

class _ApprovalRequestsViewState extends State<ApprovalRequestsView> {
  static const int _pendingTab = 0;
  int _selectedTabIndex = _pendingTab;

  void _openDetails(int requestId) {
    context.read<ApprovalRequestsCubit>().refreshRequests();
    Navigator.push(
      context,
      MaterialPageRoute<void>(
        builder: (_) => ApprovalRequestDetailsView(requestId: requestId),
      ),
    );
  }

  String _pendingSubtitle(int count) {
    if (count == 0) return 'لا توجد طلبات قيد المراجعة';
    if (count == 1) return 'طلب واحد قيد المراجعة';
    if (count == 2) return 'طلبان قيد المراجعة';
    if (count <= 10) return '$count طلبات قيد المراجعة';
    return '$count طلبًا قيد المراجعة';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.scaffoldBackground,
      body: SafeArea(
        child: BlocBuilder<ApprovalRequestsCubit, ApprovalRequestsState>(
          builder: (context, state) {
            if (state is ApprovalRequestsInitial ||
                state is ApprovalRequestsLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state is ApprovalRequestsFailure) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        state.message,
                        textAlign: TextAlign.center,
                        style: AppStyles.bodyRegular,
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: 200,
                        child: CustomButton(
                          label: 'إعادة المحاولة',
                          icon: Icons.refresh_rounded,
                          onTap: () {
                            context
                                .read<ApprovalRequestsCubit>()
                                .loadRequests();
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }

            if (state is ApprovalRequestsSuccess) {
              final pending = state.requests.where((r) => r.isPending).toList();
              final completed = state.requests
                  .where((r) => !r.isPending)
                  .toList();

              final visible = _selectedTabIndex == _pendingTab
                  ? pending
                  : completed;

              final requests = state.requests;

              if (requests.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40),
                  child: Center(
                    child: Text(
                      _selectedTabIndex == _pendingTab
                          ? 'لا توجد طلبات قيد المراجعة'
                          : 'لا توجد طلبات منتهية',
                      style: TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 14,
                      ),
                    ),
                  ),
                );
              }
              final isOnline = context.watch<ConnectivityCubit>().state;
              return RefreshIndicator(
                onRefresh: () =>
                    context.read<ApprovalRequestsCubit>().refreshRequests(),
                child: ListView(
                  physics: AlwaysScrollableScrollPhysics(),
                  padding: EdgeInsets.fromLTRB(0, isOnline ? 16 : 0, 0, 24),
                  children: [
                    if (!isOnline) ...[
                      const OfflineBanner(),
                      const SizedBox(height: 12),
                    ],
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Align(
                        alignment: AlignmentDirectional.centerStart,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'طلبات الموافقة',
                              style: AppStyles.screenHeader,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _pendingSubtitle(pending.length),
                              style: AppStyles.screenSubheader,
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: TabBarWidget(
                        selectedIndex: _selectedTabIndex,
                        onTabSelected: (index) =>
                            setState(() => _selectedTabIndex = index),
                        pendingCount: pending.length,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (visible.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 40,
                          horizontal: 16,
                        ),
                        child: Center(
                          child: Text(
                            _selectedTabIndex == _pendingTab
                                ? 'لا توجد طلبات قيد المراجعة'
                                : 'لا توجد طلبات منتهية',
                            style: const TextStyle(
                              color: AppColors.textMuted,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      )
                    else
                      for (final request in visible)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: ApprovalRequestCard(
                            request: request,
                            operation: state.operationFor(request.requestId),
                            onTap: () => _openDetails(request.requestId),
                          ),
                        ),
                  ],
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }
}
