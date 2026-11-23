import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_approval_app/core/app_theme.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_data.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_requests_view.dart';

class ShopApprovalApp extends StatefulWidget {
  const ShopApprovalApp({super.key});

  @override
  State<ShopApprovalApp> createState() => _ShopApprovalAppState();
}

class _ShopApprovalAppState extends State<ShopApprovalApp> {

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ApprovalRequestsCubit(
        MockApprovalApi(initialRequests: createMockApprovalRequests()),
      )..loadRequests(),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: ApprovalRequestsView(),
      ),
    );
  }
}
