import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_data.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_requests_page.dart';

class ShopApprovalApp extends StatelessWidget {
  const ShopApprovalApp({super.key});


  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalRequestsCubit(
        MockApprovalApi(initialRequests: createMockApprovalRequests()),
      )..loadRequests(),
      child: MaterialApp(
        title: 'موافقة صاحب المحل',
        debugShowCheckedModeBanner: false,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const ApprovalRequestsPage(),
      ),
    );
  }
}
