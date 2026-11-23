import 'package:flutter/foundation.dart';
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
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/features/approvals/presentation/utils/approval_request_presentation.dart';
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
        builder: (context, child) => Stack(
          fit: StackFit.expand,
          children: [
            child!,
            if (kDebugMode)
              Positioned(
                top: 0,
                left: 0,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: _DebugPanel(api: _api),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _DebugPanel extends StatelessWidget {
  const _DebugPanel({required this.api});

  final MockApprovalApi api;

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<ApprovalRequestsCubit>();

    return Material(
      color: const Color(0xA6000000),
      borderRadius: BorderRadius.circular(20),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.bolt_rounded, color: Colors.white),
            onPressed: () {
              final state = cubit.state;
              if (state is! ApprovalRequestsSuccess) return;

              final id = cubit.viewingRequestId ?? 4;
              final request = state.requests
                  .where((item) => item.requestId == id)
                  .firstOrNull;

              if (request == null || !request.isPending) return;

              api.simulateExternalChange(
                id,
                amountInPiastres: request.amountInPiastres + 50000,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: cubit.refreshRequests,
          ),
        ],
      ),
    );
  }
}
