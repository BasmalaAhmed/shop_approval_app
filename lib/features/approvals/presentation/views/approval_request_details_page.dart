import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_detail_row.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_notice.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_status_chip.dart';
import 'package:shop_approval_app/models/approval_decision.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestDetailsPage extends StatelessWidget {
  const ApprovalRequestDetailsPage({super.key, required this.requestId});

  final int requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0XFFF1F0EA),
      appBar: AppBar(
        title: const Text('تفاصيل الطلب'),
        backgroundColor: Color(0XFFF1F0EA),
      ),
      body: BlocBuilder<ApprovalRequestsCubit, ApprovalRequestsState>(
        builder: (context, state) {
          if (state is ApprovalRequestsFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: ApprovalNotice(
                  title: 'تعذر تحميل الطلبات',
                  message: state.message,
                ),
              ),
            );
          }
          if (state is ApprovalRequestsSuccess) {
            final matchingRequests = state.requests.where(
              (item) => item.requestId == requestId,
            );

            if (matchingRequests.isEmpty) {
              return const Center(child: Text('الطلب غير موجود'));
            }

            final request = matchingRequests.first;
            final operation = state.operationFor(requestId);
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
                    if (request.attentionMessage?.trim().isNotEmpty == true)
                      ApprovalNotice(
                        title: 'تنبيه',
                        message: request.attentionMessage!,
                      ),
                    const SizedBox(height: 12),
                    ApprovalStatusChip(
                      status: request.status,
                      lastDecision: request.lastDecision,
                    ),
                    if (request.status == ApprovalStatus.approved &&
                        request.executedAsEmployee != null)
                      ApprovalDetailRow(
                        label: 'نُفذت العملية باسم',
                        value: request.executedAsEmployee!,
                      ),
                    const SizedBox(height: 20),
                    if (operation is DecisionSubmitting ||
                        operation is DecisionCheckingOutcome) ...[
                      const Center(child: CircularProgressIndicator()),
                      const SizedBox(height: 8),
                      const Text('جار متابعة القرار...'),
                    ] else if (operation is DecisionUnknownOutcome) ...[
                      ApprovalNotice(
                        title: 'النتيجة غير مؤكدة',
                        message:
                            operation.message ?? 'تعذر تأكيد نتيجة القرار.',
                      ),
                      const SizedBox(height: 8),
                      ApprovalButton(
                        label: 'تحقق من النتيجة',
                        onTap: () {
                          context
                              .read<ApprovalRequestsCubit>()
                              .checkDecisionOutcome(requestId);
                        },
                      ),
                      ApprovalButton(
                        label: 'أعد إرسال نفس القرار',
                        onTap: () {
                          context
                              .read<ApprovalRequestsCubit>()
                              .retryUnknownDecision(requestId);
                        },
                      ),
                    ] else ...[
                      if (operation is DecisionConflict)
                        const ApprovalNotice(
                          title: 'تم تحديث الطلب',
                          message:
                              'تغيّرت بيانات الطلب من جهاز آخر. يرجى مراجعة البيانات.',
                        ),

                      if (operation is DecisionFailure)
                        ApprovalNotice(
                          title: 'تعذر تنفيذ القرار',
                          message: operation.message,
                        ),
                      if (request.status == ApprovalStatus.pending) ...[
                        const SizedBox(height: 8),
                        ApprovalButton(
                          label: 'موافقة',
                          onTap: () {
                            context
                                .read<ApprovalRequestsCubit>()
                                .submitDecision(
                                  requestId,
                                  ApprovalDecision.approve,
                                );
                          },
                        ),
                        ApprovalButton(
                          label: 'رفض',
                          buttonColor: Colors.red,
                          onTap: () {
                            context
                                .read<ApprovalRequestsCubit>()
                                .submitDecision(
                                  requestId,
                                  ApprovalDecision.reject,
                                );
                          },
                        ),
                      ],
                    ],
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
