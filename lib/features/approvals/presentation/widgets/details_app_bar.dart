import 'package:flutter/material.dart';
import 'package:shop_approval_app/core/app_styles.dart';
import 'package:shop_approval_app/models/approval_request.dart';

class DetailsAppBar extends StatelessWidget implements PreferredSizeWidget {
  const DetailsAppBar({super.key, this.request, this.isNewVersion = false});

  final ApprovalRequest? request;
  final bool isNewVersion;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      centerTitle: false,
      titleSpacing: 0,
      shape: Border(bottom: BorderSide(color: Color(0XFFE4E7EC))),
      title: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('تفاصيل الطلب', style: AppStyles.appBarTitle),
          if (request != null) ...[
            const SizedBox(height: 2),
            Text(
              'نسخة ${request!.version}${isNewVersion ? ' (جديدة)' : ''} · طلب رقم ${request!.requestId}',
              style: AppStyles.appBarSubtitle,
            ),
          ],
        ],
      ),
    );
  }
}
