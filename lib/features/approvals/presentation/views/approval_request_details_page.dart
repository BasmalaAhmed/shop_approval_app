import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_status_chip.dart';

class ApprovalRequestDetailsPage extends StatelessWidget {
  const ApprovalRequestDetailsPage({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('تفاصيل الطلب')),
      body: BlocBuilder<ApprovalRequestsCubit, ApprovalRequestsState>(
        builder: (context, state) {
          if (state is ApprovalRequestsFailure) {
            return Center(child: Text(state.message));
          }
          if (state is ApprovalRequestsSuccess) {
            final matchingRequests = state.requests.where(
              (item) => item.requestId == requestId,
            );

            if (matchingRequests.isEmpty) {
              return const Center(child: Text('الطلب غير موجود'));
            }

            final request = matchingRequests.first;
            final pounds = request.amountInPiastres ~/ 100;
            final piastres = request.amountInPiastres % 100;

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ApprovalDetailRow(
                      label: 'اسم الموظف',
                      value: request.employeeName,
                    ),
                    const SizedBox(height: 12),
                    ApprovalDetailRow(
                      label: 'الفرع',
                      value: request.branchName,
                    ),
                    const SizedBox(height: 12),
                    ApprovalDetailRow(
                      label: 'المبلغ',
                      value:
                          '$pounds.${piastres.toString().padLeft(2, '0')} جنيه',
                    ),
                    const SizedBox(height: 12),
                    ApprovalDetailRow(label: 'السبب', value: request.reason),
                    const SizedBox(height: 12),
                    ApprovalStatusChip(
                      status: request.status,
                      lastDecision: request.lastDecision,
                    ),
                  ],
                ),
              ),
            );
          }
          return const Center(child: CircularProgressIndicator());
        },
      ),
    );
  }
}
