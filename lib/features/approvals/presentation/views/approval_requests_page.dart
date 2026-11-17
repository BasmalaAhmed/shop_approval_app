import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_request_details_page.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_request_card.dart';

class ApprovalRequestsPage extends StatefulWidget {
  const ApprovalRequestsPage({super.key});

  @override
  State<ApprovalRequestsPage> createState() => _ApprovalRequestsPageState();
}

class _ApprovalRequestsPageState extends State<ApprovalRequestsPage> {
  @override
  void initState() {
    super.initState();

    context.read<ApprovalRequestsCubit>().loadRequests();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('طلبات الموافقة')),
      body: BlocBuilder<ApprovalRequestsCubit, ApprovalRequestsState>(
        builder: (context, state) {
          if (state is ApprovalRequestsInitial ||
              state is ApprovalRequestsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApprovalRequestsFailure) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(state.message),
                  const SizedBox(height: 12),
                  ApprovalButton(
                    label: 'إعادة المحاولة',
                    onTap: () {
                      context.read<ApprovalRequestsCubit>().loadRequests();
                    },
                  ),
                ],
              ),
            );
          }

          if (state is ApprovalRequestsSuccess) {
            final requests = state.requests;

            if (requests.isEmpty) {
              return const Center(child: Text('لا توجد طلبات موافقة حاليا'));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final request = requests[index];

                return InkWell(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute<void>(
                        builder: (context) => ApprovalRequestDetailsPage(
                          requestId: request.requestId,
                        ),
                      ),
                    );
                  },
                  child: ApprovalRequestCard(
                    request: request,
                    operation: state.operationFor(request.requestId),
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 12);
              },
              itemCount: requests.length,
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }
}
