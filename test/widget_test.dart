import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';

void main() {
  testWidgets('shows approval requests in Arabic', (WidgetTester tester) async {
    await tester.pumpWidget(const ShopApprovalApp());
    await tester.pumpAndSettle();

    expect(find.text('طلبات الموافقة'), findsOneWidget);
    expect(find.text('أحمد محمود'), findsOneWidget);
  });
}
