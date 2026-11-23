import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';
import 'package:shop_approval_app/features/approvals/data/approval_api.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_cubit.dart';
import 'package:shop_approval_app/features/approvals/presentation/manager/approval_requests_cubit/approval_requests_state.dart';
import 'package:shop_approval_app/models/approval_decision_command.dart';
import 'package:shop_approval_app/models/approval_decision_result.dart';
import 'package:shop_approval_app/models/approval_request.dart';

import 'helpers/approval_test_data.dart';

void main() {
  testWidgets('shows approval requests in Arabic', (WidgetTester tester) async {
    await tester.pumpWidget(
      ShopApprovalApp(connectivity: FakeConnectivityService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('طلبات الموافقة'), findsOneWidget);
    expect(find.text('أحمد محمود'), findsOneWidget);
  });

  group('refreshRequests', () {
    test('picks up changes made elsewhere while the request is open', () async {
      final api = _ScriptedApi()..next = [buildRequest()];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.next = [buildRequest(version: 2, amountInPiastres: 999900)];
      await cubit.refreshRequests();

      final request = (cubit.state as ApprovalRequestsSuccess).requests.single;
      expect(request.version, 2);
      expect(request.amountInPiastres, 999900);
    });

    test('ignores a stale response with an older version', () async {
      final api = _ScriptedApi()..next = [buildRequest(version: 2)];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => true);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      api.next = [buildRequest(version: 1)];
      await cubit.refreshRequests();

      final request = (cubit.state as ApprovalRequestsSuccess).requests.single;
      expect(request.version, 2);
    });

    test('does not call the api while offline', () async {
      final api = _ScriptedApi()..next = [buildRequest()];
      final cubit = ApprovalRequestsCubit(api, isOnline: () => false);
      addTearDown(cubit.close);
      await cubit.loadRequests();

      await cubit.refreshRequests();

      expect(api.fetchCount, 1);
    });
  });
}

class _ScriptedApi implements ApprovalApi {
  List<ApprovalRequest> next = [];
  int fetchCount = 0;

  @override
  Future<List<ApprovalRequest>> fetchRequests() async {
    fetchCount++;
    return next;
  }

  @override
  Future<ApprovalDecisionResult?> findDecisionById(String decisionId) async =>
      null;

  @override
  Future<ApprovalDecisionResult> submitDecision(
    ApprovalDecisionCommand command,
  ) async {
    throw UnimplementedError();
  }
}
