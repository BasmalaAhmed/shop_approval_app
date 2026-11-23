import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shop_approval_app/app/auto_refresh.dart';
import 'package:shop_approval_app/core/app_theme.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_cubit.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';
import 'package:shop_approval_app/features/approvals/data/mock_api_scenario.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_api.dart';
import 'package:shop_approval_app/features/approvals/data/mock_approval_data.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/views/approval_requests_view.dart';

class ShopApprovalApp extends StatefulWidget {
  const ShopApprovalApp({super.key, required this.connectivity});
  final ConnectivityService connectivity;

  @override
  State<ShopApprovalApp> createState() => _ShopApprovalAppState();
}

class _ShopApprovalAppState extends State<ShopApprovalApp> {
  static const String _scenarioName = String.fromEnvironment(
    'SCENARIO',
    defaultValue: 'normal',
  );
  static const bool _simulateExternalChange = bool.fromEnvironment(
    'EXTERNAL_CHANGE',
  );

  static MockApiScenario _scenarioFromName(String name) {
    return MockApiScenario.values.firstWhere(
      (scenario) => scenario.name == name,
      orElse: () => MockApiScenario.normal,
    );
  }

  late final MockApprovalApi _api = MockApprovalApi(
    initialRequests: createMockApprovalRequests(),
    scenario: _scenarioFromName(_scenarioName),
    finalRejectionRequestIds: const {4},
  );

  Timer? _demoTimer;

  @override
  void initState() {
    super.initState();

    if (_simulateExternalChange) {
      _demoTimer = Timer(const Duration(seconds: 10), () {
        _api.simulateExternalChange(
          4,
          amountInPiastres: 999900,
          attentionMessage: 'تم تعديل المبلغ من جهاز آخر',
        );
      });
    }
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(
          create: (context) => ConnectivityCubit(widget.connectivity),
        ),
        BlocProvider(
          create: (context) => ApprovalRequestsCubit(
            _api,
            isOnline: () => widget.connectivity.isOnline,
          )..loadRequests(),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.lightTheme,
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: const AutoRefresh(child: ApprovalRequestsView()),
      ),
    );
  }
}
