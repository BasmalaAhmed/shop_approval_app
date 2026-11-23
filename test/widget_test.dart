import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';

void main() {
  testWidgets('shows approval requests in Arabic, right to left', (
    tester,
  ) async {
    await tester.pumpWidget(
      ShopApprovalApp(connectivity: FakeConnectivityService()),
    );
    await tester.pumpAndSettle();

    expect(find.text('طلبات الموافقة'), findsOneWidget);
    expect(find.text('أحمد محمود'), findsOneWidget);

    final context = tester.element(find.text('طلبات الموافقة'));
    expect(Directionality.of(context), TextDirection.rtl);
  });
}
