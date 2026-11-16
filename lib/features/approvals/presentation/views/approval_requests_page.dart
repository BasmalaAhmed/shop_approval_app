import 'package:flutter/material.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_request_details_page.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/approval_request_card.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class ApprovalRequestsPage extends StatelessWidget {
  const ApprovalRequestsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final requests = [
      ApprovalRequest(
        requestId: 1,
        employeeName: 'أحمد محمود',
        branchName: "فرع مدينة نصر",
        amountInPiastres: 125500,
        reason: "شراء مستلزمات للمحل",
        version: 1,
        status: ApprovalStatus.pending,
      ),
      ApprovalRequest(
        requestId: 2,
        employeeName: 'محمد محسن',
        branchName: "فرع أكتوبر",
        amountInPiastres: 159806,
        reason: "شراء مستلزمات للمحل",
        version: 1,
        status: ApprovalStatus.rejected,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text('طلبات الموافقة')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemBuilder: (context, index) {
          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute<void>(
                  builder: (context) =>
                      ApprovalRequestDetailsPage(request: requests[index]),
                ),
              );
            },
            child: ApprovalRequestCard(request: requests[index]),
          );
        },
        separatorBuilder: (context, index) {
          return const SizedBox(height: 12);
        },
        itemCount: requests.length,
      ),
    );
  }
}
