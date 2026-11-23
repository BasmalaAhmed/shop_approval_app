import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/app/shop_approval_app.dart';
import 'package:shop_approval_app/core/connectivity/connectivity_service.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/buttons/custom_button.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/details_bottom_bar.dart';

void main() {
  testWidgets('approving updates the details and the list together', (
    tester,
  ) async {
    await tester.pumpWidget(
      ShopApprovalApp(connectivity: FakeConnectivityService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('أحمد محمود'));
    await tester.pumpAndSettle();
    expect(find.text('تفاصيل الطلب'), findsOneWidget);

    await tester.tap(
      find.descendant(
        of: find.byType(DetailsBottomBar),
        matching: find.byType(CustomButton),
      ),
    );
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('تمت الموافقة'), findsWidgets);
    expect(find.textContaining('باسم أحمد محمود'), findsOneWidget);

    await tester.tap(find.text('العودة إلى الطلبات'));
    await tester.pumpAndSettle();
    await tester.tap(find.textContaining('منتهي').first);
    await tester.pumpAndSettle();

    expect(find.text('تمت الموافقة'), findsOneWidget);
    expect(find.textContaining('باسم أحمد محمود'), findsOneWidget);
  });

  testWidgets('rejecting sends the request back to draft', (tester) async {
    await tester.pumpWidget(
      ShopApprovalApp(connectivity: FakeConnectivityService()),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('أحمد محمود'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('رفض'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('تأكيد الرفض'));
    await tester.pump(const Duration(milliseconds: 400));
    await tester.pumpAndSettle();

    expect(find.text('مرفوض - عادت لمسودة'), findsWidgets);
    expect(
      find.textContaining('عاد الطلب مسودة عند أحمد محمود'),
      findsOneWidget,
    );
  });
}
