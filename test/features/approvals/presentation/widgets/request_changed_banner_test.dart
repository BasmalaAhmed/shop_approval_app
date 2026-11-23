import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shop_approval_app/features/approvals/presentation/widgets/banners/request_changed_banner.dart';
import 'package:shop_approval_app/models/request_change.dart';
import '../../../../helpers/approval_test_data.dart';

void main() {
  testWidgets('banner shows the old value next to the new one', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ar'),
        supportedLocales: const [Locale('ar')],
        localizationsDelegates: GlobalMaterialLocalizations.delegates,
        home: Scaffold(
          body: RequestChangedBanner(
            change: RequestChange(
              previous: buildRequest(amountInPiastres: 125500),
              latest: buildRequest(version: 2, amountInPiastres: 134000),
            ),
          ),
        ),
      ),
    );

    expect(find.text('الطلب تغيّر أثناء عرضه'), findsOneWidget);
    expect(find.textContaining('1,255.00', findRichText: true), findsOneWidget);
    expect(find.textContaining('1,340.00', findRichText: true), findsOneWidget);
  });
}